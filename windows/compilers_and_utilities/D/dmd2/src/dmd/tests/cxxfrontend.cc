/**
 * Test the C++ compiler interface of the
 * $(LINK2 https://www.dlang.org, D programming language).
 *
 * Copyright:   Copyright (C) 2017-2019 by The D Language Foundation, All Rights Reserved
 * Authors:     Iain Buclaw
 * License:     $(LINK2 https://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Source:      $(LINK2 https://github.com/dlang/dmd/blob/master/src/tests/cxxfrontend.c, _cxxfrontend.c)
 */

#include "root/array.h"
#include "root/bitarray.h"
#include "root/complex_t.h"
#include "root/ctfloat.h"
#include "root/dcompat.h"
#include "root/dsystem.h"
#include "root/filename.h"
#include "root/longdouble.h"
#include "root/object.h"
#include "root/optional.h"
#include "common/outbuffer.h"
#include "root/port.h"
#include "root/rmem.h"

#include "aggregate.h"
#include "aliasthis.h"
#include "arraytypes.h"
#include "ast_node.h"
#include "attrib.h"
#include "compiler.h"
#include "cond.h"
#include "ctfe.h"
#include "declaration.h"
#include "doc.h"
#include "dsymbol.h"
#include "enum.h"
#include "errors.h"
#include "expression.h"
#include "globals.h"
#include "hdrgen.h"
#include "identifier.h"
#include "id.h"
#include "import.h"
#include "init.h"
#include "json.h"
#include "mangle.h"
#include "module.h"
#include "mtype.h"
#include "nspace.h"
#include "objc.h"
#include "scope.h"
#include "statement.h"
#include "staticassert.h"
#include "target.h"
#include "template.h"
#include "tokens.h"
#include "version.h"
#include "visitor.h"

/**********************************/

extern "C" int rt_init();
extern "C" void gc_disable();

static void frontend_init()
{
    rt_init();
    gc_disable();

    global._init();
    global.vendor = "Front-End Tester";
    global.params.objname = NULL;

    target.os = Target::OS_linux;
    target.is64bit = true;
    target.cpu = CPU::native;
    target._init(global.params);

    Type::_init();
    Id::initialize();
    Module::_init();
    Expression::_init();
    Objc::_init();
    CTFloat::initialize();
}

/**********************************/

extern "C" int rt_term();
extern "C" void gc_enable();

static void frontend_term()
{
  gc_enable();
  rt_term();
}

/**********************************/

void test_tokens()
{
    // First valid TOK value
    assert((unsigned)TOK::leftParenthesis == 1);
    assert(strcmp(Token::toChars(TOK::leftParenthesis), "(") == 0);

    // Last valid TOK value
    assert((unsigned)TOK::attribute__ == (unsigned)TOK::MAX - 1);
    assert(strcmp(Token::toChars(TOK::attribute__), "__attribute__") == 0);
}

void test_compiler_globals()
{
    // only check constant prefix of version
    assert(strncmp(global.versionChars(), "v2.", 3) == 0);
    unsigned versionNumber = global.versionNumber();
    assert(versionNumber >= 2060 && versionNumber <= 3000);

    assert(strcmp(target.architectureName.ptr, "X86_64") == 0 ||
           strcmp(target.architectureName.ptr, "X86") == 0);
}

/**********************************/

class TestVisitor : public Visitor
{
  using Visitor::visit;

  public:
    bool expr;
    bool package;
    bool stmt;
    bool type;
    bool aggr;
    bool attrib;
    bool decl;
    bool typeinfo;
    bool idexpr;
    bool function;

    TestVisitor() : expr(false), package(false), stmt(false), type(false),
        aggr(false), attrib(false), decl(false), typeinfo(false), idexpr(false),
        function(false)
    {
    }

    void visit(Expression *)
    {
        expr = true;
    }

    void visit(IdentifierExp *)
    {
        idexpr = true;
    }

    void visit(Package *)
    {
        package = true;
    }

    void visit(Statement *)
    {
        stmt = true;
    }

    void visit(AttribDeclaration *)
    {
        attrib = true;
    }

    void visit(Declaration *)
    {
        decl = true;
    }

    void visit(AggregateDeclaration *)
    {
        aggr = true;
    }

    void visit(TypeNext *)
    {
        type = true;
    }

    void visit(TypeInfoDeclaration *)
    {
        typeinfo = true;
    }

    void visit(FuncDeclaration *)
    {
        function = true;
    }
};

void test_visitors()
{
    TestVisitor tv;
    Loc loc;
    Identifier *ident = Identifier::idPool("test");

    IntegerExp *ie = IntegerExp::create(loc, 42, Type::tint32);
    ie->accept(&tv);
    assert(tv.expr == true);

    IdentifierExp *id = IdentifierExp::create (loc, ident);
    id->accept(&tv);
    assert(tv.idexpr == true);

    Module *mod = Module::create("test", ident, 0, 0);
    assert(mod->isModule() == mod);
    mod->accept(&tv);
    assert(tv.package == true);

    ExpStatement *es = ExpStatement::create(loc, ie);
    assert(es->isExpStatement() == es);
    es->accept(&tv);
    assert(tv.stmt == true);

    TypePointer *tp = TypePointer::create(Type::tvoid);
    assert(tp->hasPointers() == true);
    tp->accept(&tv);
    assert(tv.type == true);

    LinkDeclaration *ld = LinkDeclaration::create(loc, LINK::d, NULL);
    assert(ld->isAttribDeclaration() == static_cast<AttribDeclaration *>(ld));
    assert(ld->linkage == LINK::d);
    ld->accept(&tv);
    assert(tv.attrib == true);

    ClassDeclaration *cd = ClassDeclaration::create(loc, Identifier::idPool("TypeInfo"), NULL, NULL, true);
    assert(cd->isClassDeclaration() == cd);
    assert(cd->vtblOffset() == 1);
    cd->accept(&tv);
    assert(tv.aggr == true);

    AliasDeclaration *ad = AliasDeclaration::create(loc, ident, tp);
    assert(ad->isAliasDeclaration() == ad);
    ad->storage_class = STCabstract;
    assert(ad->isAbstract() == true);
    ad->accept(&tv);
    assert(tv.decl == true);

    cd = ClassDeclaration::create(loc, Identifier::idPool("TypeInfo_Pointer"), NULL, NULL, true);
    TypeInfoPointerDeclaration *ti = TypeInfoPointerDeclaration::create(tp);
    assert(ti->isTypeInfoDeclaration() == ti);
    assert(ti->tinfo == tp);
    ti->accept(&tv);
    assert(tv.typeinfo == true);

    Parameters *args = new Parameters;
    TypeFunction *tf = TypeFunction::create(args, Type::tvoid, VARARGnone, LINK::c);
    FuncDeclaration *fd = FuncDeclaration::create(Loc (), Loc (), Identifier::idPool("test"),
                                                  STCextern, tf);
    assert(fd->isFuncDeclaration() == fd);
    assert(fd->type == tf);
    fd->accept(&tv);
    assert(tv.function == true);
}

/**********************************/

void test_semantic()
{
    /* Mini object.d source. Module::parse will add internal members also. */
    const char *buf =
        "module object;\n"
        "class Object { }\n"
        "class Throwable { }\n"
        "class Error : Throwable { this(immutable(char)[]); }";

    DArray<unsigned char> src = DArray<unsigned char>(strlen(buf), (unsigned char *)mem.xstrdup(buf));

    Module *m = Module::create("object.d", Identifier::idPool("object"), 0, 0);

    unsigned errors = global.startGagging();

    m->src = src;
    m->parse();
    m->importedFrom = m;
    m->importAll(NULL);
    dsymbolSemantic(m, NULL);
    semantic2(m, NULL);
    semantic3(m, NULL);

    Dsymbol *s = m->search(Loc(), Identifier::idPool("Error"));
    assert(s);
    AggregateDeclaration *ad = s->isAggregateDeclaration();
    assert(ad && ad->ctor && ad->sizeok == Sizeok::done);
    CtorDeclaration *ctor = ad->ctor->isCtorDeclaration();
    assert(ctor->isMember() && !ctor->isNested());
    assert(0 == strcmp(ctor->type->toChars(), "Error(string)"));

    ClassDeclaration *cd = ad->isClassDeclaration();
    assert(cd && cd->hasMonitor());

    assert(!global.endGagging(errors));
}

/**********************************/

void test_skip_importall()
{
    /* Similar to test_semantic(), but importAll step is skipped.  */
    const char *buf =
        "module rootobject;\n"
        "class RootObject : Object { }";

    DArray<unsigned char> src = DArray<unsigned char>(strlen(buf), (unsigned char *)mem.xstrdup(buf));

    Module *m = Module::create("rootobject.d", Identifier::idPool("rootobject"), 0, 0);

    unsigned errors = global.startGagging();

    m->src = src;
    m->parse();
    m->importedFrom = m;
    dsymbolSemantic(m, NULL);
    semantic2(m, NULL);
    semantic3(m, NULL);

    assert(!global.endGagging(errors));
}

/**********************************/

void test_expression()
{
    Loc loc;
    IntegerExp *ie = IntegerExp::create(loc, 42, Type::tint32);
    Expression *e = ie->ctfeInterpret();

    assert(e);
    assert(e->isConst());

    Optional<bool> res = e->toBool();
    assert(res.get());
}

/**********************************/

void test_target()
{
    assert(target.isVectorOpSupported(Type::tint32, EXP::pow));
}

/**********************************/

void test_emplace()
{
    Loc loc;
    UnionExp ue;

    IntegerExp::emplace(&ue, loc, 1065353216, Type::tint32);
    Expression *e = ue.exp();
    assert(e->op == EXP::int64);
    assert(e->toInteger() == 1065353216);

    UnionExp ure;
    Expression *re = Compiler::paintAsType(&ure, e, Type::tfloat32);
    assert(re->op == EXP::float64);
    assert(re->toReal() == CTFloat::one);

    UnionExp uie;
    Expression *ie = Compiler::paintAsType(&uie, re, Type::tint32);
    assert(ie->op == EXP::int64);
    assert(ie->toInteger() == e->toInteger());
}

/**********************************/

void test_parameters()
{
    Parameters *args = new Parameters;
    args->push(Parameter::create(STCundefined, Type::tint32, NULL, NULL, NULL));
    args->push(Parameter::create(STCundefined, Type::tint64, NULL, NULL, NULL));

    TypeFunction *tf = TypeFunction::create(args, Type::tvoid, VARARGnone, LINK::c);

    assert(tf->parameterList.length() == 2);
    assert(tf->parameterList[0]->type == Type::tint32);
    assert(tf->parameterList[1]->type == Type::tint64);
    assert(!tf->isDstyleVariadic());
}

/**********************************/

void test_types()
{
    Parameters *args = new Parameters;
    StorageClass stc = STCnothrow|STCproperty|STCreturn|STCreturninferred|STCtrusted;
    TypeFunction *tfunction = TypeFunction::create(args, Type::tvoid, VARARGnone, LINK::d, stc);

    assert(tfunction->isnothrow());
    assert(!tfunction->isnogc());
    assert(tfunction->isproperty());
    assert(!tfunction->isref());
    tfunction->isref(true);
    assert(tfunction->isref());
    assert(tfunction->isreturn());
    assert(!tfunction->isScopeQual());
    assert(tfunction->isreturninferred());
    assert(!tfunction->isscopeinferred());
    assert(tfunction->linkage == LINK::d);
    assert(tfunction->trust == TRUST::trusted);
    assert(tfunction->purity == PURE::impure);
}

/**********************************/

void test_location()
{
    Loc loc1 = Loc("test.d", 24, 42);
    assert(loc1.equals(Loc("test.d", 24, 42)));
    assert(strcmp(loc1.toChars(true, MESSAGESTYLEdigitalmars), "test.d(24,42)") == 0);
    assert(strcmp(loc1.toChars(true, MESSAGESTYLEgnu), "test.d:24:42") == 0);
}

/**********************************/

void test_array()
{
    Array<double> array;
    array.setDim(4);
    array.shift(10);
    array.push(20);
    array[2] = 15;
    assert(array[0] == 10);
    assert(array.find(10) == 0);
    assert(array.find(20) == 5);
    assert(!array.contains(99));
    array.remove(1);
    assert(array.length == 5);
    assert(array[1] == 15);
    assert(array.pop() == 20);
    assert(array.length == 4);
    array.insert(1, 30);
    assert(array[1] == 30);
    assert(array[2] == 15);

    Array<int> arrayA;
    array.setDim(0);
    int buf[3] = {10, 15, 20};
    arrayA.push(buf[0]);
    arrayA.push(buf[1]);
    arrayA.push(buf[2]);
    assert(memcmp(arrayA.tdata(), buf, sizeof(buf)) == 0);
    Array<int> *arrayPtr = arrayA.copy();
    assert(arrayPtr);
    assert(memcmp(arrayPtr->tdata(), arrayA.tdata(), arrayA.length * sizeof(int)) == 0);
    assert(arrayPtr->tdata() != arrayA.tdata());

    arrayPtr->setDim(0);
    int buf2[2] = {100, 200};
    arrayPtr->push(buf2[0]);
    arrayPtr->push(buf2[1]);

    arrayA.append(arrayPtr);
    assert(memcmp(arrayA.tdata() + 3, buf2, sizeof(buf2)) == 0);
    arrayA.insert(0, arrayPtr);
    assert(arrayA[0] == 100);
    assert(arrayA[1] == 200);
    assert(arrayA[2] == 10);
    assert(arrayA[3] == 15);
    assert(arrayA[4] == 20);
    assert(arrayA[5] == 100);
    assert(arrayA[6] == 200);

    arrayA.zero();
    for (size_t i = 0; i < arrayA.length; i++)
        assert(arrayA[i] == 0);
}

void test_outbuffer()
{
    OutBuffer buf;
    mangleToBuffer(Type::tint64, &buf);
    assert(strcmp(buf.peekChars(), "l") == 0);
    buf.reset();

    buf.reserve(16);
    buf.writestring("hello");
    buf.writeByte(' ');
    buf.write(&buf);
    buf.writenl();
    assert(buf.length() == 13);

    const char *data = buf.extractChars();
    assert(buf.length() == 0);
    assert(strcmp(data, "hello hello \n") == 0);
}

void test_cppmangle()
{
    // Based off runnable_cxx/cppa.d.
    const char *buf =
        "module cppa;\n"
        "extern (C++):\n"
        "class Base { void based() { } }\n"
        "interface Interface { int MethodCPP(); int MethodD(); }\n"
        "class Derived : Base, Interface { int MethodCPP(); int MethodD() { return 3; } }";

    DArray<unsigned char> src = DArray<unsigned char>(strlen(buf), (unsigned char *)mem.xstrdup(buf));

    Module *m = Module::create("cppa.d", Identifier::idPool("cppa"), 0, 0);

    unsigned errors = global.startGagging();
    FuncDeclaration *fd;
    const char *mangle;

    m->src = src;
    m->parse();
    m->importedFrom = m;
    m->importAll(NULL);
    dsymbolSemantic(m, NULL);
    semantic2(m, NULL);
    semantic3(m, NULL);

    Dsymbol *s = m->search(Loc(), Identifier::idPool("Derived"));
    assert(s);
    ClassDeclaration *cd = s->isClassDeclaration();
    assert(cd && cd->sizeok == Sizeok::done);
    assert(cd->members && cd->members->length == 2);
    assert(cd->vtblInterfaces && cd->vtblInterfaces->length == 1);
    BaseClass *b = (*cd->vtblInterfaces)[0];

    fd = (*cd->members)[0]->isFuncDeclaration();
    assert(fd);
    mangle = cppThunkMangleItanium(fd, b->offset);
    assert(strcmp(mangle, "_ZThn8_N7Derived9MethodCPPEv") == 0);

    fd = (*cd->members)[1]->isFuncDeclaration();
    assert(fd);
    mangle = cppThunkMangleItanium(fd, b->offset);
    assert(strcmp(mangle, "_ZThn8_N7Derived7MethodDEv") == 0);

    assert(fd->fbody);
    auto rs = (*fd->fbody->isCompoundStatement()->statements)[0]->isReturnStatement();
    assert(rs);
    assert(!canThrow(rs->exp, fd, false));

    assert(!global.endGagging(errors));
}

void test_module()
{
    unsigned errors = global.startGagging();
    Module *mod = Module::load(Loc(), NULL, Identifier::idPool("doesnotexist.d"));
    assert(mod == NULL);
    assert(global.endGagging(errors));
}

void test_optional()
{
    Optional<bool> opt = Optional<bool>::create(true);
    assert(!opt.isEmpty());
    assert(opt.isPresent());
    assert(opt.get() == true);
    assert(opt.hasValue(true));
}

/**********************************/

class MiniGlueVisitor : public Visitor
{
    using Visitor::visit;
    FuncDeclaration *func;
public:
    MiniGlueVisitor(FuncDeclaration *func)
        : func(func)
    {
    }

    void visit(Type *) { assert(0); }
    void visit(TypeError *t) { (void)t->ctype; }
    void visit(TypeNull *t) { (void)t->ctype; }
    void visit(TypeNoreturn *t) { (void)t->ctype; }
    void visit(TypeBasic *t)
    {
        switch (t->ty)
        {
        case TY::Tvoid:
        case TY::Tbool:
        case TY::Tint8:
        case TY::Tuns8:
        case TY::Tint16:
        case TY::Tuns16:
        case TY::Tint32:
        case TY::Tuns32:
        case TY::Tint64:
        case TY::Tuns64:
        case TY::Tint128:
        case TY::Tuns128:
        case TY::Tfloat32:
        case TY::Tfloat64:
        case TY::Tfloat80:
        case TY::Timaginary32:
        case TY::Timaginary64:
        case TY::Timaginary80:
        case TY::Tcomplex32:
        case TY::Tcomplex64:
        case TY::Tcomplex80:
        case TY::Tchar:
        case TY::Twchar:
        case TY::Tdchar:
            (void)t->ctype; break;
        default:
            assert(0);
        }
        (void)t->toChars();
    }
    void visit(TypePointer *t)
    {
        t->next->accept(this);
        (void)t->ctype;
    }
    void visit(TypeDArray *t)
    {
        t->next->accept(this);
        Type::tsize_t->accept(this);
        (void)t->ctype;
        (void)t->toChars();
    }
    void visit(TypeSArray *t)
    {
        if (t->dim->isConst() && t->dim->type->isintegral())
        {
            (void)t->dim->toUInteger();
            t->next->accept(this);
            (void)t->ctype;
        }
        else
            assert(0);
    }
    void visit(TypeVector *t)
    {
        (void)t->basetype->isTypeSArray()->dim->toUInteger();
        t->elementType()->accept(this);
        if (t->ty == TY::Tvoid)
            Type::tuns8->accept(this);
        (void)t->ctype;
        (void)t->toChars();
    }
    void visit(TypeAArray *t)
    {
        (void)t->ctype;
        (void)t->toChars();
    }
    void visit(TypeFunction *t)
    {
        if (t->isDstyleVariadic())
            Type::typeinfotypelist->type->accept(this);
        for (size_t i = 0; i < t->parameterList.length(); i++)
        {
            Parameter *arg = t->parameterList[i];
            (void)arg->storageClass;
            arg->type->accept(this);
        }
        if (t->parameterList.varargs != VARARGvariadic)
            Type::tvoid->accept(this);
        if (t->next != NULL)
        {
            t->next->accept(this);
            (void)t->isref();
        }
        (void)t->ctype;
        switch (t->linkage)
        {
        case LINK::windows:
        case LINK::c:
        case LINK::cpp:
        case LINK::d:
        case LINK::objc:
            break;
        default:
            assert(0);
        }
    }
    void visit(TypeDelegate *t)
    {
        t->next->accept(this);
        Type::tvoidptr->accept(this);
        (void)t->ctype;
        (void)t->toChars();
    }
    void visitUserAttributes(Dsymbol *sym)
    {
        if (!sym->userAttribDecl)
            return;
        Expressions *attrs = sym->userAttribDecl->getAttributes();
        if (attrs)
        {
            expandTuples(attrs);
            for (size_t i = 0; i < attrs->length; i++)
            {
                Expression *attr = (*attrs)[i];
                Dsymbol *sym = attr->type->toDsymbol(0);
                if (!sym)
                {
                    if (TemplateExp *te = attr->isTemplateExp())
                    {
                        if (!te->td || !te->td->onemember)
                            continue;
                        sym = te->td->onemember;
                    }
                    else
                        continue;
                }
                sym->getModule()->accept(this);
                if (attr->op == EXP::call)
                    attr = attr->ctfeInterpret();
                if (attr->op != EXP::structLiteral)
                    continue;
            }
        }
    }
    void visit(TypeEnum *t)
    {
        if (t->sym->memtype)
            t->sym->memtype->accept(this);
        if (t->sym->isSpecial())
        {
            (void)t->toChars();
            (void)t->ctype;
            t->sym->accept(this);
        }
        else if (t->sym->ident == NULL)
        {
            (void)t->ctype;
        }
        else
        {
            (void)t->ctype;
            (void)t->size(t->sym->loc);
            if (t->sym->members)
            {
                for (size_t i = 0; i < t->sym->members->length; i++)
                {
                    EnumMember *member = (*t->sym->members)[i]->isEnumMember();
                    if (member == NULL)
                        continue;
                    (void)member->ident->toChars();
                    (void)member->value()->toInteger();
                }
            }
        }
        visitUserAttributes(t->sym);
    }
    void visit(TypeStruct *t)
    {
        t->sym->accept(this);
        (void)t->sym->isUnionDeclaration();
        (void)t->ctype;
        if (t->sym->members)
        {
            (void)t->sym->structsize;
            (void)t->sym->alignment.isDefault();
            (void)t->sym->alignsize;
            (void)t->sym->alignment.get();
            (void)t->sym->isPOD();
            for (size_t i = 0; i < t->sym->members->length; i++)
            {
                Dsymbol *sym = (*t->sym->members)[i];
                if (VarDeclaration *var = sym->isVarDeclaration())
                {
                    (void)var->csym;
                    (void)var->aliassym;
                    (void)var->isField();
                    (void)var->ident->toChars();
                    continue;
                }
                if (AnonDeclaration *ad = sym->isAnonDeclaration())
                {
                    (void)ad->isunion;
                    (void)ad->loc;
                    (void)ad->decl;
                    (void)ad->anonoffset;
                    (void)ad->anonstructsize;
                    (void)ad->anonalignsize;
                    continue;
                }
                if (AttribDeclaration *attrib = sym->isAttribDeclaration())
                {
                    (void)attrib->include(NULL);
                    continue;
                }
                if (sym->isTemplateMixin() || sym->isNspace())
                {
                    if (ScopeDsymbol *scopesym = sym->isScopeDsymbol())
                    {
                        (void)scopesym->members;
                        continue;
                    }
                }
            }
        }
        visitUserAttributes(t->sym);
    }
    void visit(TypeClass *t)
    {
        t->sym->accept(this);
        (void)t->ctype;
        if (ClassDeclaration *cd = t->sym->isClassDeclaration())
        {
            (void)cd->baseClass;
            cd->type->accept(this);
            if (InterfaceDeclaration *id = cd->isInterfaceDeclaration())
                (void)id->vtblInterfaces->length;
            (void)cd->hasMonitor();
            if (cd->vtblInterfaces)
            {
                for (size_t i = 0; i < cd->vtblInterfaces->length; i++)
                {
                    BaseClass *bc = (*cd->vtblInterfaces)[i];
                    (void)bc->offset;
                }
            }
        }
        if (t->sym->members)
        {
            (void)t->sym->structsize;
            (void)t->sym->alignsize;
            for (size_t i = 0; i < t->sym->members->length; i++)
            {
                Dsymbol *sym = (*t->sym->members)[i];
                if (VarDeclaration *var = sym->isVarDeclaration())
                {
                    (void)var->csym;
                    (void)var->aliassym;
                    (void)var->isField();
                    (void)var->ident->toChars();
                    continue;
                }
                if (AnonDeclaration *ad = sym->isAnonDeclaration())
                {
                    (void)ad->isunion;
                    (void)ad->loc;
                    (void)ad->decl;
                    (void)ad->anonoffset;
                    (void)ad->anonstructsize;
                    (void)ad->anonalignsize;
                    continue;
                }
                if (AttribDeclaration *attrib = sym->isAttribDeclaration())
                {
                    (void)attrib->include(NULL);
                    continue;
                }
                if (sym->isTemplateMixin() || sym->isNspace())
                {
                    if (ScopeDsymbol *scopesym = sym->isScopeDsymbol())
                    {
                        (void)scopesym->members;
                        continue;
                    }
                }
            }
        }
        (void)t->sym->storage_class;
        t->sym->type->accept(this);
        for (size_t i = 0; i < t->sym->vtbl.length; i++)
            t->sym->vtbl[i]->isFuncDeclaration()->accept(this);
        for (size_t i = 0; i < t->sym->baseclasses->length; i++)
        {
            BaseClass *bc = (*t->sym->baseclasses)[i];
            bc->sym->accept(this);
        }
        visitUserAttributes(t->sym);
    }
    void visit(Statement *) { assert(0); }
    void visit(ScopeGuardStatement *) { }
    void visit(IfStatement *s)
    {
        s->condition->accept(this);
        s->condition->type->accept(this);
        if (s->ifbody)
            s->ifbody->accept(this);
        if (s->elsebody)
            s->elsebody->accept(this);
    }
    void visit(PragmaStatement *) { }
    void visit(WhileStatement *) { assert(0); }
    void visit(DoStatement *s)
    {
        s->getRelatedLabeled()->accept(this);
        if (s->_body)
            s->_body->accept(this);
        s->condition->accept(this);
        s->condition->type->accept(this);
    }
    void visit(ForStatement *s)
    {
        s->getRelatedLabeled()->accept(this);
        if (s->_init)
            s->_init->accept(this);
        if (s->condition)
        {
            s->condition->accept(this);
            s->condition->type->accept(this);
        }
        if (s->_body)
            s->_body->accept(this);
        if (s->increment)
            s->increment->accept(this);
    }
    void visit(ForeachStatement *) { assert(0); }
    void visit(ForeachRangeStatement *) { assert(0); }
    void visit(BreakStatement *s)
    {
        if (s->ident)
        {
            LabelDsymbol *sym = func->searchLabel(s->ident, s->loc);
            LabelStatement *label = sym->statement;
            label->statement->getRelatedLabeled()->accept(this);
        }
    }
    void visit(ContinueStatement *s)
    {
        if (s->ident)
        {
            LabelDsymbol *sym = func->searchLabel(s->ident, s->loc);
            LabelStatement *label = sym->statement;
            label->statement->accept(this);
        }
    }
    void visit(GotoStatement *s)
    {
        assert(s->label->statement != NULL);
        assert(s->tf == s->label->statement->tf);
        (void)s->label->ident;
    }
    void visit(LabelStatement *s)
    {
        LabelDsymbol *sym;
        if (func->returnLabel && func->returnLabel->ident == s->ident)
            sym = func->returnLabel;
        else
            sym = func->searchLabel(s->ident, s->loc);
        sym->statement->accept(this);
        if (sym == func->returnLabel && func->fensure != NULL)
            func->fensure->accept(this);
        else if (s->statement)
            s->statement->accept(this);
    }
    void visit(SwitchStatement *s)
    {
        s->getRelatedLabeled()->accept(this);
        s->condition->accept(this);
        Type *condtype = s->condition->type->toBasetype();
        if (!condtype->isscalar())
            assert(0);
        if (s->cases)
        {
            for (size_t i = 0; i < s->cases->length; i++)
            {
                CaseStatement *cs = (*s->cases)[i];
                if (s->hasVars)
                    cs->exp->accept(this);
            }
            s->sdefault->accept(this);
        }
        if (s->_body)
            s->_body->accept(this);
    }
    void visit(CaseStatement *s)
    {
        s->getRelatedLabeled()->accept(this);
        if (s->exp->type->isscalar())
            s->exp->accept(this);
        else
            (void)s->index;
        if (s->statement)
            s->statement->accept(this);
    }
    void visit(DefaultStatement *s)
    {
        s->getRelatedLabeled()->accept(this);
        if (s->statement)
            s->statement->accept(this);
    }
    void visit(GotoDefaultStatement *s)
    {
        s->sw->sdefault->accept(this);
    }
    void visit(GotoCaseStatement *s)
    {
        s->cs->accept(this);
    }
    void visit(SwitchErrorStatement *s)
    {
        s->exp->accept(this);
    }
    void visit(ReturnStatement *s)
    {
        if (s->exp == NULL || s->exp->type->toBasetype()->ty == TY::Tvoid)
            return;
        TypeFunction *tf = func->type->toTypeFunction();
        Type *type = func->tintro != NULL ? func->tintro->nextOf() : tf->nextOf();
        if ((func->isMain() || func->isCMain()) && type->toBasetype()->ty == TY::Tvoid)
            type = Type::tint32;
        if (func->shidden)
        {
            func->accept(this);
            if (func->isNRVO() && func->nrvo_var)
                return;
            StructLiteralExp *sle = NULL;
            if (DotVarExp *dve = (s->exp->isCallExp()
                                  ? s->exp->isCallExp()->e1->isDotVarExp() : NULL))
            {
                if (dve->var->isCtorDeclaration())
                {
                    if (CommaExp *ce = dve->e1->isCommaExp())
                    {
                        DeclarationExp *de = ce->e1->isDeclarationExp();
                        VarExp *ve = ce->e2->isVarExp();
                        if (de && ve && ve->var == de->declaration &&
                            ve->var->storage_class & STCtemp)
                        {
                            ve->var->accept(this);
                        }
                    }
                    else
                        sle = dve->e1->isStructLiteralExp();
                }
            }
            else
                sle = s->exp->isStructLiteralExp();
            if (sle != NULL)
            {
                type->baseElemOf()->isTypeStruct()->sym->accept(this);
                sle->sym = func->shidden;
            }
            s->exp->accept(this);
        }
        else if (tf->next->ty == TY::Tnoreturn)
            s->exp->accept(this);
        else
            s->exp->accept(this);
    }
    void visit(ExpStatement *s)
    {
        if (s->exp)
            s->exp->accept(this);
    }
    void visit(CompoundStatement *s)
    {
        if (s->statements == NULL)
            return;
        for (size_t i = 0; i < s->statements->length; i++)
        {
            Statement *statement = (*s->statements)[i];
            if (statement)
                statement->accept(this);
        }
    }
    void visit(UnrolledLoopStatement *s)
    {
        if (s->statements == NULL)
            return;
        s->getRelatedLabeled()->accept(this);
        for (size_t i = 0; i < s->statements->length; i++)
        {
            Statement *statement = (*s->statements)[i];
            if (statement != NULL)
                statement->accept(this);
        }
    }
    void visit(ScopeStatement *s)
    {
        if (s->statement == NULL)
            return;
        s->statement->accept(this);
    }
    void visit(WithStatement *s)
    {
        if (s->wthis)
        {
            s->wthis->accept(this);
            s->wthis->_init->isExpInitializer()->exp->accept(this);
        }
        if (s->_body)
            s->_body->accept(this);
    }
    void visit(ThrowStatement *s)
    {
        s->exp->type->toBasetype()->isClassHandle()->accept(this);
        s->exp->accept(this);
    }
    void visit(TryCatchStatement *s)
    {
        if (s->_body)
            s->_body->accept(this);
        if (s->catches)
        {
            for (size_t i = 0; i < s->catches->length; i++)
            {
                Catch *vcatch = (*s->catches)[i];
                vcatch->type->accept(this);
                vcatch->type->isClassHandle()->accept(this);
                if (vcatch->var)
                    vcatch->var->accept(this);
                if (vcatch->handler)
                    vcatch->handler->accept(this);
            }
        }
    }
    void visit(TryFinallyStatement *s)
    {
        if (s->_body)
            s->_body->accept(this);
        if (s->finalbody)
            s->finalbody->accept(this);
    }
    void visit(SynchronizedStatement *)
    {
        assert(0);
    }
    void visit(AsmStatement *)
    {
        assert(0);
    }
    void visit(GccAsmStatement *s)
    {
        s->insn->accept(this);
        if (s->args)
        {
            for (size_t i = 0; i < s->args->length; i++)
            {
                (void)(*s->names)[i]->toChars();
                (*s->constraints)[i]->toStringExp()->accept(this);
                (*s->args)[i]->accept(this);
                (void)s->outputargs;
            }
        }
        if (s->clobbers)
        {
            for (size_t i = 0; i < s->clobbers->length; i++)
                (*s->clobbers)[i]->toStringExp()->accept(this);
        }
        if (s->labels)
        {
            for (size_t i = 0; i < s->labels->length; i++)
            {
                (void)(*s->labels)[i]->toChars();
                GotoStatement *gs = (*s->gotos)[i];
                gs->label->statement->accept(this);
                (void)gs->label->ident;
            }
        }
    }
    void visit(ImportStatement *s)
    {
        if (s->imports == NULL)
            return;
        for (size_t i = 0; i < s->imports->length; i++)
        {
            Dsymbol *dsym = (*s->imports)[i];
            if (dsym != NULL)
                dsym->accept(this);
        }
    }
    void visit(Dsymbol *) { assert(0); }
    void visit(Module *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        if (d->members)
        {
            for (size_t i = 0; i < d->members->length; i++)
            {
                Dsymbol *s = (*d->members)[i];
                s->accept(this);
            }
            ClassDeclarations aclasses;
            for (size_t i = 0; i < d->members->length; i++)
            {
                Dsymbol *member = (*d->members)[i];
                member->addLocalClass(&aclasses);
            }
            for (size_t i = 0; i < d->aimports.length; i++)
            {
                Module *mi = d->aimports[i];
                if (mi->needmoduleinfo)
                    mi->accept(this);
            }
            (void)d->findGetMembers();
            (void)d->sctor;
            (void)d->sdtor;
            (void)d->ssharedctor;
            (void)d->sshareddtor;
            (void)d->sictor;
            (void)d->stest;
            (void)d->needmoduleinfo;
        }
        d->semanticRun = PASS::obj;
    }
    void visit(Import *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        if (d->isstatic)
            return;
        if (d->ident == NULL)
        {
            for (size_t i = 0; i < d->names.length; i++)
            {
                d->aliasdecls[i]->accept(this);
                (void)d->aliases[i]->toChars();
            }
        }
        else
            d->mod->accept(this);
        d->semanticRun = PASS::obj;
    }
    void visit(TupleDeclaration *d)
    {
        for (size_t i = 0; i < d->objects->length; i++)
        {
            RootObject *o = (*d->objects)[i];
            if (o->dyncast() == DYNCAST_EXPRESSION)
            {
                DsymbolExp *de = ((Expression *) o)->isDsymbolExp();
                if (de && de->s->isDeclaration())
                    de->s->accept(this);
            }
        }
    }
    void visit(AttribDeclaration *d)
    {
        Dsymbols *ds = d->include(NULL);
        if (!ds)
            return;
        for (size_t i = 0; i < ds->length; i++)
            (*ds)[i]->accept(this);
    }
    void visit(PragmaDeclaration *d)
    {
        visit((AttribDeclaration *)d);
    }
    void visit(ConditionalDeclaration *d)
    {
        (void)d->condition->isVersionCondition();
        visit((AttribDeclaration *)d);
    }
    void visit(Nspace *d)
    {
        if (isError(d) || !d->members)
            return;
        for (size_t i = 0; i < d->members->length; i++)
            (*d->members)[i]->accept(this);
    }
    void visit(TemplateDeclaration *d)
    {
        if (!func || !func->isAuto())
            return;
        Type *tb = func->type->nextOf()->baseElemOf();
        while (tb->ty == TY::Tarray || tb->ty == TY::Tpointer)
            tb = tb->nextOf()->baseElemOf();
        TemplateInstance *ti = NULL;
        if (tb->ty == TY::Tstruct)
            ti = tb->isTypeStruct()->sym->isInstantiated();
        else if (tb->ty == TY::Tclass)
            ti = tb->isTypeClass()->sym->isInstantiated();
        if (ti && ti->tempdecl == d)
            ti->accept(this);
    }
    void visit(TemplateInstance *d)
    {
        if (isError(d) || !d->members)
            return;
        if (!d->needsCodegen())
            return;
        for (size_t i = 0; i < d->members->length; i++)
            (*d->members)[i]->accept(this);
    }
    void visit(TemplateMixin *d)
    {
        if (isError(d) || !d->members)
            return;
        for (size_t i = 0; i < d->members->length; i++)
            (*d->members)[i]->accept(this);
    }
    void visit(StructDeclaration *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        if (d->type->ty == TY::Terror)
            return;
        d->type->accept(this);
        if (d->isAnonymous() || !d->members)
            return;
        (void)d->sinit;
        StructLiteralExp *sle = StructLiteralExp::create(d->loc, d, NULL);
        if (!d->fill(d->loc, sle->elements, true))
            assert(0);
        sle->type = d->type;
        sle->accept(this);
        for (size_t i = 0; i < d->members->length; i++)
            (*d->members)[i]->accept(this);
        if (d->xeq && d->xeq != d->xerreq)
            d->xeq->accept(this);
        if (d->xcmp && d->xcmp != d->xerrcmp)
            d->xcmp->accept(this);
        if (d->xhash)
            d->xhash->accept(this);
        d->semanticRun = PASS::obj;
    }
    void visit(ClassDeclaration *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        if (d->type->ty == TY::Terror)
            return;
        if (!d->members)
            return;
        for (size_t i = 0; i < d->members->length; i++)
            (*d->members)[i]->accept(this);
        for (size_t i = d->vtblOffset(); i < d->vtbl.length; i++)
        {
            FuncDeclaration *fd = d->vtbl[i]->isFuncDeclaration();
            if (!fd || (!fd->fbody && d->isAbstract()))
                continue;
            if (!fd->functionSemantic())
                return;
            if (!d->isFuncHidden(fd) || fd->isFuture())
                continue;
            for (size_t j = 1; j < d->vtbl.length; j++)
            {
                if (j == i)
                    continue;
                FuncDeclaration *fd2 = d->vtbl[j]->isFuncDeclaration();
                if (!fd2->ident->equals(fd->ident))
                    continue;
                if (fd2->isFuture())
                    continue;
                if (fd->leastAsSpecialized(fd2) != MATCH::nomatch ||
                    fd2->leastAsSpecialized(fd) != MATCH::nomatch)
                {
                    return;
                }
            }
        }
        (void)d->csym;
        (void)d->vtblSymbol()->csym;
        (void)d->sinit;
        NewExp *ne = NewExp::create(d->loc, NULL, d->type, NULL);
        ne->type = d->type;
        Expression *e = ne->ctfeInterpret();
        assert(e->op == EXP::classReference);
        ClassReferenceExp *exp = e->isClassReferenceExp();
        ClassDeclaration *cd = exp->originalClass();
        exp->value->stype->accept(this);
        cd->accept(this);
        for (ClassDeclaration *bcd = cd; bcd != NULL; bcd = bcd->baseClass)
        {
            for (size_t i = 0; i < bcd->vtblInterfaces->length; i++)
            {
                BaseClass *bc = (*bcd->vtblInterfaces)[i];
                for (ClassDeclaration *cd2 = cd; 1; cd2 = cd2->baseClass)
                {
                    assert(cd2 != NULL);
                    for (size_t i = 0; i < cd2->vtblInterfaces->length; i++)
                    {
                        BaseClass *b = (*cd2->vtblInterfaces)[i];
                        if (b == bc)
                            break;
                        (void)b->sym->vtbl.length;
                    }
                    for (ClassDeclaration *cd3 = cd2->baseClass; cd3; cd3 = cd3->baseClass)
                    {
                        for (size_t k = 0; k < cd3->vtblInterfaces->length; k++)
                        {
                            BaseClass *bs = (*cd3->vtblInterfaces)[k];
                            if (bs->fillVtbl(cd2, NULL, 0))
                            {
                                if (bc == bs)
                                    break;
                                (void)bs->sym->vtbl.length;
                            }
                        }
                    }
                }
                (void)bc->offset;
            }
            for (size_t i = 0; i < bcd->fields.length; i++)
            {
                VarDeclaration *vfield = bcd->fields[i];
                size_t index = exp->findFieldIndexByName(vfield);
                Expression *value = (*exp->value->elements)[index];
                if (!value)
                    continue;
                vfield->accept(this);
                value->accept(this);
            }
        }
        for (size_t i = d->vtblOffset(); i < d->vtbl.length; i++)
        {
            FuncDeclaration *fd = d->vtbl[i]->isFuncDeclaration();
            if (fd && (fd->fbody || !d->isAbstract()))
                visitDeclaration(fd);
        }
        d->type->accept(this);
        d->semanticRun = PASS::obj;
    }
    void visit(InterfaceDeclaration *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        if (d->type->ty == TY::Terror)
            return;
        if (!d->members)
            return;
        for (size_t i = 0; i < d->members->length; i++)
            (*d->members)[i]->accept(this);
        (void)d->csym;
        d->type->accept(this);
        d->semanticRun = PASS::obj;
    }
    void visit(EnumDeclaration *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        if (d->errors || d->type->ty == TY::Terror)
            return;
        if (d->isAnonymous())
            return;
        TypeEnum *tc = d->type->isTypeEnum();
        if (tc->sym->members && !d->type->isZeroInit())
        {
            (void)d->sinit;
            tc->sym->defaultval->accept(this);
        }
        d->type->accept(this);
        d->semanticRun = PASS::obj;
    }
    void visitDeclaration(Declaration *decl)
    {
        if (decl->csym)
            return;
        if (SymbolDeclaration *sd = decl->isSymbolDeclaration())
        {
            sd->dsym->accept(this);
            return;
        }
        if (TypeInfoDeclaration *tinfo = decl->isTypeInfoDeclaration())
        {
            tinfo->accept(this);
            return;
        }
        if (FuncAliasDeclaration *fad = decl->isFuncAliasDeclaration())
            return visitDeclaration(fad->funcalias);
        if (decl->isField())
        {
            decl->toParent()->isAggregateDeclaration()->type->accept(this);
            return;
        }
        if (FuncDeclaration *fd = decl->isFuncDeclaration())
        {
            if (!fd->functionSemantic())
                return;
            if (fd->needThis() && !fd->isMember2())
                return;
            (void)decl->ident->toChars();
            fd->type->accept(this);
            (void)fd->fbody;
            (void)fd->hasDualContext();
            AggregateDeclaration *ad = fd->isMember2();
            (void)fd->isNested();
            fd->isThis()->accept(this);
            ad->handleType()->accept(this);
            (void)fd->isVirtual();
            (void)fd->vtblIndex;
            if (fd->inlining == PINLINE::always || fd->inlining == PINLINE::never)
                (void)fd->inlining;
            if (fd->isCrtCtor() || fd->isCrtDtor())
                (void)fd->flags;
            (void)fd->isNaked();
            (void)fd->isGenerated();
            (void)fd->ident;
            (void)fd->storage_class;
            (void)fd->type->nextOf()->isTypeNoreturn();
        }
        else
        {
            VarDeclaration *vd = decl->isVarDeclaration();
            (void)vd->isParameter();
            (void)vd->canTakeAddressOf();
            vd->type->accept(this);
            (void)vd->alignment.isDefault();
            (void)vd->alignment.get();
            (void)vd->storage_class;
            if (vd->storage_class & STCmanifest)
            {
                if (vd->_init && !vd->_init->isVoidInitializer())
                {
                    Expression *ie = initializerToExpression(vd->_init);
                    ie->accept(this);
                }
            }
        }
        if (decl->isCodeseg() || decl->isDataseg())
        {
            if (decl->mangleOverride.length)
                (void)decl->mangleOverride.ptr;
            (void)decl->isInstantiated();
            (void)decl->toPrettyChars(true);
        }
        if ((decl->storage_class & STCtemp) ||
            (decl->storage_class & STCvolatile) ||
            (decl->storage_class & STCdeprecated))
        {
            (void)decl->storage_class;
        }
        if (decl->visibility.kind == Visibility::private_ ||
            decl->visibility.kind == Visibility::protected_)
        {
            (void)decl->visibility.kind;
        }
        (void)decl->isImportedSymbol();
        (void)decl->isExport();
        if (decl->isThreadlocal())
            (void)decl->csym;
        visitUserAttributes(decl);
    }
    void visit(VarDeclaration *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        if (d->type->ty == TY::Terror)
            return;
        if (d->type->isTypeNoreturn())
        {
            if (!d->isDataseg() && !d->isMember() &&
                d->_init && !d->_init->isVoidInitializer())
            {
                Expression *e = d->type->defaultInitLiteral(d->loc);
                e->accept(this);
            }
            return;
        }
        if (d->aliassym)
        {
            d->toAlias()->accept(this);
            return;
        }
        if (!d->canTakeAddressOf())
        {
            if (!d->type->isscalar())
                visitDeclaration(d);
        }
        else if (d->isDataseg() && !(d->storage_class & STCextern))
        {
            visitDeclaration(d);
            (void)d->type->size(d->loc);
            if (d->_init)
            {
                if (!d->_init->isVoidInitializer())
                {
                    Expression *e = initializerToExpression(d->_init, d->type);
                    e->accept(this);
                }
            }
            else
            {
                Expression *e = d->type->defaultInitLiteral(d->loc);
                e->accept(this);
            }
        }
        else if (!d->isDataseg() && !d->isMember())
        {
            visitDeclaration(d);
            if (d->_init && !d->_init->isVoidInitializer())
            {
                ExpInitializer *vinit = d->_init->isExpInitializer();
                initializerToExpression(vinit)->accept(this);
                if (d->needsScopeDtor())
                    d->edtor->accept(this);
            }
        }
        d->type->accept(this);
        d->semanticRun = PASS::obj;
    }
    void visit(TypeInfoDeclaration *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        visitDeclaration(d);
        d->semanticRun = PASS::obj;
    }
    void visit(FuncDeclaration *d)
    {
        if (d->semanticRun >= PASS::obj)
            return;
        if (d->isUnitTestDeclaration())
            return;
        if (TypeFunction *tf = d->type->isTypeFunction())
        {
            if (tf->next == NULL || tf->next->ty == TY::Terror)
                return;
        }
        if (d->hasSemantic3Errors())
            return;
        if (d->isNested())
        {
            FuncDeclaration *fdp = d;
            while (fdp && fdp->isNested())
            {
                fdp = fdp->toParent2()->isFuncDeclaration();
                if (fdp == NULL)
                    break;
                if (fdp->hasSemantic3Errors())
                    return;
            }
        }
        if (d->semanticRun < PASS::semantic3)
        {
            d->functionSemantic3();
            Module::runDeferredSemantic3();
        }
        if (global.errors)
            return;
        visitDeclaration(d);
        if (!d->fbody)
            return;
        assert(d->semanticRun == PASS::semantic3done);
        d->semanticRun = PASS::obj;
        if (d->vthis)
            visitDeclaration(d->vthis);
        if (d->v_arguments)
            visitDeclaration(d->v_arguments);
        for (size_t i = 0; i < (d->parameters ? d->parameters->length : 0); i++)
        {
            VarDeclaration *param = (*d->parameters)[i];
            visitDeclaration(param);
            if (param->type->ty == TY::Tnoreturn)
                break;
        }
        if (AggregateDeclaration *ad = d->isThis())
        {
            while (ad->isNested())
            {
                Dsymbol *pd = ad->toParent2();
                visitDeclaration(ad->vthis);
                ad = pd->isAggregateDeclaration();
                if (ad == NULL)
                    break;
            }
        }
        for (size_t i = 0; i < d->closureVars.length; i++)
        {
            VarDeclaration *v = d->closureVars[i];
            if (!v->isParameter())
                continue;
            visitDeclaration(v);
        }
        if (d->vresult)
            visitDeclaration(d->vresult);
        if (d->isNRVO() && d->nrvo_var)
            visitDeclaration(d->nrvo_var);
        d->fbody->accept(this);
        if (d->v_argptr)
            visitDeclaration(d->v_argptr);
    }
};

void test_backend(FuncDeclaration *f, Type *t)
{
    MiniGlueVisitor v(f);
    if (t->isNaked())
        t->accept(&v);
    else
    {
        Type *tb = t->castMod(0);
        tb->accept(&v);
        (void)t->mod;
    }
    f->fbody->accept(&v);
}

/**********************************/

int main(int argc, char **argv)
{
    frontend_init();

    test_tokens();
    test_compiler_globals();
    test_visitors();
    test_semantic();
    test_skip_importall();
    test_expression();
    test_target();
    test_emplace();
    test_parameters();
    test_types();
    test_location();
    test_array();
    test_outbuffer();
    test_cppmangle();
    test_module();
    test_optional();

    frontend_term();

    return 0;
}
