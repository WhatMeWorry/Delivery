
module model;

import common;


import std.stdio   : writeln;
import std.string  : toStringz, lastIndexOf;
import gl3n.linalg : vec2, vec3;
import std.file    : getcwd;


class Model 
{
public:
    // Model Data
    // Stores all the textures loaded so far, 
    // optimized to make sure textures aren't loaded more than once.

    Texture[] textures_loaded;	
    Mesh[]    meshes;
    string    directory;
    bool      gammaCorrection;

    //  Functions 
    // Constructor, expects a filepath to a 3D model.
    this(string path, bool gamma = false)
    {
        writeAndPause("inside Model Constructor");
        this.gammaCorrection = false;
        this.loadModel(path);
    }

    // Draws the model, and thus all its meshes
    void draw(Shader shader)
    {
        for(GLuint i = 0; i < this.meshes.length; i++)
        {
            writeln("i = ", i);
            this.meshes[i].draw(shader);
        }
    }

private:

    // Loads a model with supported ASSIMP extensions from file and stores the resulting meshes in the meshes vector.
    void loadModel(string path)
    {
        const char[] cStr = path.dup ~ '\0';

        // This is C++ AssImp,   D can't do C++, only C
        // Assimp::Importer importer;
        // const aiScene* scene = importer.ReadFile(path, aiProcess_Triangulate | 
        //                                          aiProcess_FlipUVs | aiProcess_CalcTangentSpace);

        // This is C API for AssImp
        const aiScene* scene = aiImportFile(cStr.ptr, // parameter signature says const char *pFile
                                            aiProcess_Triangulate | 
                                            aiProcess_FlipUVs |
                                            aiProcess_CalcTangentSpace);
        if(!scene)
            writeAndPause("aiImportFile failed on file " ~ path);
        else
            writeAndPause("Object file successfully imported from file " ~ path );

        //writeln("loadModel:scene.mNumMeshes = ", scene.mNumMeshes);
        //aiMesh**      mMeshes;
        //writeln("loadModel:scene.mNumMaterials = ", scene.mNumMaterials);
        //writeln("cStr (path) = ", cStr);
        
		string currentWorkingDir = getcwd();
        writeln("currentWorkingDir = ", currentWorkingDir); // N:\LearnOpenGLdeVries\03_01_Model_Loading\Release
        
        if( (!scene) || (scene.mFlags == AI_SCENE_FLAGS_INCOMPLETE) || (!scene.mRootNode) )
        {
            writeAndPause("Something is wrong with ");
            return;
        }
        // Retrieve the directory path of the filepath
        //this->directory = path.substr(0, path.find_last_of('/'));

        auto last = lastIndexOf(path, '/');
        //writeln("last = ", last);             // 2
        string justPath = path[0..last];
        //writeln("justPath = ", justPath);     // ..
        this.directory =  path[0..last].idup;   //lastIndexOf(pathAndFile, '\')
        //writeln("this.directory = ", this.directory);  // ..

        //writeAndPause(" ");

        //writeln(" call processNode from loadModel");

        // Process ASSIMP's root node recursively
        this.processNode(scene.mRootNode, scene);    // Root node starts everything off...
        //writeAndPause("original call to processNode with root node has returned... ");
    }

    // To find all the Asset Import types go to:
    // https://github.com/DerelictOrg/DerelictASSIMP3/blob/master/source/derelict/assimp3/types.d

    string aiStringToDstring(aiString aiStr)
    {
        size_t len = aiStr.length;
        string str = aiStr.data[0..len].idup;
        return(str);
    }


    // Processes a node in a recursive fashion. Processes each individual mesh 
    // located at the node and repeats this process on its children nodes (if any).
    void processNode(const aiNode* node, const aiScene* scene)
    {
        size_t length;
        char[MAXLEN] data;
        size_t len = node.mName.length;
        string temp = node.mName.data[0..len].idup;
        writeln("processNode  node.mName.data = ", temp); 
        writeln("processNode  node.mNumChildren = ", node.mNumChildren); 
        writeln("processNode  node.mNumMeshes = ", node.mNumMeshes); 

        // Process each mesh located at the current node
        for(GLuint i = 0; i < node.mNumMeshes; i++)
        {
            // The node object only contains indices to index the actual objects in the scene. 
            // The scene contains all the data, node is just to keep stuff organized (like 
            // relations between nodes).
            const aiMesh* mesh = scene.mMeshes[node.mMeshes[i]]; 
 
            //this->meshes.push_back(this->processMesh(mesh, scene));
            //this.processMesh(mesh, scene);

            Mesh aMesh = new Mesh(null, null, null);  // allocate space for a mesh
            this.processMesh(aMesh, mesh, scene);  // fill up the mesh object with what the mesh pointer point to.

            //writeln("aMesh = ", aMesh.indices);
            aMesh.setupMesh(); 

            writeln("aMesh.VAO = ", aMesh.VAO, "  VBO = ", aMesh.VBO, "  EBO = ", aMesh.EBO);

            writeAndPause("  ");
            meshes ~= aMesh;  
            //meshes ~= *mesh; // append operator        
        }

        // After  processing all the meshes, recursively process each child node
        for(GLuint i = 0; i < node.mNumChildren; i++)
        {
            writeln(i, " < ", node.mNumChildren); 
            this.processNode(node.mChildren[i], scene);         
        }
        writeln("====  processNode returning =====");
    }

    // A Mesh object itself contains all the relevant data required for rendering, think of vertex
    // positions, normal vectors, texture coordinates, faces and the material of the object.
    // A mesh contains several faces. A Face represents a render primitive of the object (triangles,
    // squares, points). A face contains the indices of the vertices that form a primitive. Because
    // the vertices and the indices are separated, this makes it easy for us to render via an index
    // buffer

    //Mesh processMesh(aiMesh* mesh, const aiScene* scene)
    void processMesh(Mesh myMesh, const aiMesh* mesh, const aiScene* scene)
    {
        // Data to fill
        Vertex[] vertices;
        GLuint[] indices;
        Texture[] textures;

        writeln("processMesh  mesh.mNumVertices = ",    mesh.mNumVertices);
        writeln("processMesh  mesh.mPrimitiveTypes = ", mesh.mPrimitiveTypes );
        writeln("processMesh  mesh.mNumFaces = ",       mesh.mNumFaces);
        //writeln("mesh.mMaterialIndex = ",  mesh.mMaterialIndex);
        if(mesh.mName.length > 0)
        {
            writeln("processMesh  mesh.mName.length = ", mesh.mName.length);
            writeln("processMesh  mesh.mName.data = ",   mesh.mName.data[0..(mesh.mName.length)].idup);
        }
        else
        {
            //writeln("mesh.mName is nameless");
        }
        // Walk through each of the mesh's vertices
        for(GLuint i = 0; i < mesh.mNumVertices; i++)
        {
            Vertex vertex;
            vec3 vector; // We declare a placeholder vector since assimp uses its own vector class that 
                         // doesn't directly convert to glm's vec3 class so we transfer the data to this placeholder vec3 first.
            // Positions
            vector.x = mesh.mVertices[i].x;
            vector.y = mesh.mVertices[i].y;
            vector.z = mesh.mVertices[i].z;
            vertex.Position = vector;
            // Normals
            vector.x = mesh.mNormals[i].x;
            vector.y = mesh.mNormals[i].y;
            vector.z = mesh.mNormals[i].z;
            vertex.Normal = vector;
            // Texture Coordinates

            if(mesh.mTextureCoords[0]) // Does the mesh contain texture coordinates?
            {
                vec2 vec;
                // A vertex can contain up to 8 different texture coordinates. We thus make the assumption that we won't 
                // use models where a vertex can have multiple texture coordinates so we always take the first set (0).
                vec.x = mesh.mTextureCoords[0][i].x; 
                vec.y = mesh.mTextureCoords[0][i].y;
                vertex.TexCoords = vec;
            }
            else
            {
                vertex.TexCoords = vec2(0.0f, 0.0f);
            }
 
            // Tangent: needs aiProcess_CalcTangentSpace option in aiImportFile
            vector.x = mesh.mTangents[i].x;
            vector.y = mesh.mTangents[i].y;
            vector.z = mesh.mTangents[i].z;
            vertex.Tangent = vector;

            // Bitangent
            vector.x = mesh.mBitangents[i].x;
            vector.y = mesh.mBitangents[i].y;
            vector.z = mesh.mBitangents[i].z;

            vertex.Bitangent = vector;

            //vertices.push_back(vertex);
            vertices ~= vertex;
        }

        // Now walk through each of the mesh's faces (a face is a mesh its triangle) 
        // and retrieve the corresponding vertex indices.
        GLuint k;
        for(GLuint i = 0; i < mesh.mNumFaces; i++)
        {
            const aiFace face = mesh.mFaces[i];
            // Retrieve all indices of the face and store them in the indices vector
            //writeln("face.mNumIndices = ", face.mNumIndices);
            for(GLuint j = 0; j < face.mNumIndices; j++)
            {
                //indices.push_back(face.mIndices[j]);
                indices ~= face.mIndices[j]; 
            }
        }

        // A Mesh uses only a single material which is referenced by a material ID.
/+
        struct aiMaterial
        {
            C_STRUCT aiMaterialProperty** mProperties;
            unsigned int mNumProperties;  // 12
            unsigned int mNumAllocated;   // 20
        };

        struct aiMaterialProperty
        {
            C_STRUCT aiString mKey;
            unsigned int mSemantic;
            unsigned int mIndex;
            unsigned int mDataLength;
            C_ENUM aiPropertyTypeInfo mType;
            char* mData;
        };

        struct aiString
        {
        // Binary length of the string excluding the terminal 
        size_t length;
        // const size_t MAXLEN = 1024;
        char data[MAXLEN];
        };
+/

        auto b = [ __traits(allMembers, aiMaterialProperty) ];
        //writeln(b);


        // Process materials
        writeln("mesh.mMaterialIndex = ", mesh.mMaterialIndex);
        writeAndPause(" ");
        if(mesh.mMaterialIndex >= 0)
        {
            const aiMaterial* material = scene.mMaterials[mesh.mMaterialIndex];
            writeln("material.mNumProperties = ", material.mNumProperties);
            writeln("material.mNumAllocated = ", material.mNumAllocated);


            aiMaterialProperty** tempPtrToPtr;
            tempPtrToPtr = cast(aiMaterialProperty**) material.mProperties;

            aiMaterialProperty* tempPtr;
            tempPtr = cast(aiMaterialProperty*) *(material.mProperties);

            // mIndex is always zero. 
            //writeln("mIndex (index of texture) = ", (*tempPtr).mIndex );  


            //writeln("mKey.length = ", (*tempPtr).mKey.length );  
            size_t len1 = (*tempPtr).mKey.length;
            string temp1 = (*tempPtr).mKey.data[0..len1].idup;
            //writeln("mKey.data = ", temp1);
            //writeln("mDataLength = ", (*tempPtr).mDataLength ); 
            //writeln("mType (data layout in buffer) = ", (*tempPtr).mType ); 
  
            // Dstr is always  ?mat.name
            //string Dstr = aiStringToDstring((*tempPtr).mKey);
            //writeln("Dstr = ", Dstr);

            // We assume a convention for sampler names in the shaders. Each diffuse texture should be named
            // as 'texture_diffuseN' where N is a sequential number ranging from 1 to MAX_SAMPLER_NUMBER. 
            // Same applies to other texture as the following list summarizes:
            // Diffuse: texture_diffuseN
            // Specular: texture_specularN
            // Normal: texture_normalN

	        // Not in C++ code?  why did i put this here??
            //uint texCount = material.aiGetMaterialTextureCount(aiTextureType_SPECULAR);
            //writeln("texCount = ", texCount);

            //aiString* path = cast(aiString*) toStringz("path\to\file");
            //material.aiGetMaterialTexture(aiTextureType_SPECULAR, 1, &path);

            //material.GetTextureCount(aiTextureType_SPECULAR);  // take this out
            //string dStr = "I am a D string";
            //immutable char* str = toStringz("path\to\file");  // or dStr.toStringz

            // 1. Diffuse maps
            Texture[] diffuseMaps = this.loadMaterialTextures(material, aiTextureType_DIFFUSE, "texture_diffuse");
            //textures.insert(textures.end(), diffuseMaps.begin(), diffuseMaps.end());
            textures ~= diffuseMaps;

            // 2. Specular maps
            Texture[] specularMaps = this.loadMaterialTextures(material, aiTextureType_SPECULAR, "texture_specular");
            //textures.insert(textures.end(), specularMaps.begin(), specularMaps.end());
            textures ~= specularMaps;

            // 3. Normal maps
            Texture[] normalMaps = this.loadMaterialTextures(material, aiTextureType_HEIGHT, "texture_normal");
            //textures.insert(textures.end(), normalMaps.begin(), normalMaps.end());
            textures ~= normalMaps;

            // 4. Height maps
            Texture[] heightMaps = this.loadMaterialTextures(material, aiTextureType_AMBIENT, "texture_height");
            //textures.insert(textures.end(), heightMaps.begin(), heightMaps.end());
            textures ~= heightMaps;
        }
        // Return a mesh object created from the extracted mesh data

        myMesh.vertices = vertices;
        myMesh.indices = indices;
        myMesh.textures = textures;
 
        writeln("processMesh  returning");
        return;
    }


    /+   C call
    C_ENUM aiReturn aiGetMaterialTexture(const C_STRUCT aiMaterial* mat,
                                         C_ENUM aiTextureType type,
                                         unsigned int  index,
                                         C_STRUCT aiString* path,
                                         C_ENUM aiTextureMapping* mapping    /*= NULL*/,
    +/
    /+
	enum aiTextureType
	{
		aiTextureType_NONE = 0x0,
		aiTextureType_DIFFUSE = 0x1,
		aiTextureType_SPECULAR = 0x2,
		aiTextureType_AMBIENT = 0x3,
		aiTextureType_EMISSIVE = 0x4,
		aiTextureType_HEIGHT = 0x5,
		aiTextureType_NORMALS = 0x6,
		aiTextureType_SHININESS = 0x7,
		aiTextureType_OPACITY = 0x8,
		aiTextureType_DISPLACEMENT = 0x9,
		aiTextureType_LIGHTMAP = 0xA,
		aiTextureType_REFLECTION = 0xB,
		aiTextureType_UNKNOWN = 0xC,
    } +/


    // Check all material textures of a type and load texture if not already loaded
    // The required info is returned as a Texture struct.
    Texture[] loadMaterialTextures(const aiMaterial* mat, const aiTextureType type, string typeName) const
    {
        //writeln("in loadMaterialTextures");
        writeln("aiTextureType type = ", type, "    typename = ", typeName);
        Texture[] textures;

        uint materialTextureCount = aiGetMaterialTextureCount(mat, type);
        writeln("materialTextureCount = ", materialTextureCount);
        for(GLuint i = 0; i < materialTextureCount; i++)
        {
            // WRONG!! C++  mat.aiGetMaterialTexture(aiTextureType_SPECULAR, 1, &str);

			/+
			C_ENUM aiReturn aiGetMaterialTexture(const C_STRUCT aiMaterial* mat,
												 C_ENUM aiTextureType type,
												 unsigned int  index,
												 C_STRUCT aiString* path,
			@param[in] mat Pointer to the input material. May not be NULL
			*  @param[in] type Specifies the texture stack to read from (e.g. diffuse,
			*     specular, height map ...).
			*  @param[in] index Index of the texture. The function fails if the
			*     requested index is not available for this texture type.
			*     #aiGetMaterialTextureCount() can be used to determine the number of
			*     textures in a particular texture stack.
			*  @param[out] path Receives the output path
			*      This parameter must be non-null.
			+/

           aiString str;
           aiReturn result = aiGetMaterialTexture(mat, type, i, &str); 

           size_t len1 = str.length;
           string str1 = str.data[0..len1].idup;
 
           //writeln("str1 = ", "\t", "\t", "\t", "\t", "\t", "\t", str1);

            // Skip loading texture if previously loaded
            GLboolean skip = false;
            for(GLuint j = 0; j < textures_loaded.length; j++)
            {
                if(textures_loaded[j].path == str)
                {
                    textures ~= textures_loaded[j];
                    skip = true;   // texture already loaded
                    break;
                }
            }
            if(!skip)
            {   // texture has never been loaded, load it
                Texture texture;
                texture.id = TextureFromFile(str1, this.directory);
                writeln("texture.id = ", texture.id);
                texture.type = typeName;
                writeln("texture.type = ", texture.type);
                texture.path = str;
                //writeln("texture.path = ", texture.path);
                textures ~= texture;
                //this.textures_loaded ~= texture;  // Store it as texture loaded for entire model, to ensure we won't unnecesery load duplicate textures.
            }
        }
        return textures;
    }
}




GLint TextureFromFile(string file, string directory, bool gamma = false)
{
    //Generate texture ID and load texture data 

    file = directory ~ '/' ~ file;

    //writeln("file for texture is ", file);
    //writeAndPause("in TextureFromFile");

    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    // Parameters
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);


    int width,height;


    // Determine the format of the image.
    // Note: The second paramter ('size') is currently unused, and we should use 0 for it.

    FREE_IMAGE_FORMAT bitmapSignature = FreeImage_GetFileType(toStringz(file) , 0);
    //writeln("bitmapSignature is ", bitmapSignature);

    FREE_IMAGE_FORMAT formatFromFileName = FreeImage_GetFIFFromFilename(toStringz(file));
    //writeln("formatFromFileName is ", formatFromFileName);

    if (bitmapSignature != formatFromFileName)
        //writeAndPause("format from file contents does not match file name format");

    //if (FreeImage_FIFSupportsReading(bitmapSignature))
        //writeln("File format can be read");
    //else
        //writeln("File format CANNOT be read");

    if (bitmapSignature == FIF_JPEG)
        writeln("file ", file, " is in JPEG format");
    if (bitmapSignature == FIF_PNG)
        writeln("file ", file, " is in PNG format");

    // We have a known image format, so load it into a bitap
    FIBITMAP* bitmapImage = FreeImage_Load(bitmapSignature, toStringz(file));

    // Some textures apperar ﬂipped upside-down. This happens because OpenGL expects the 0.0 coordinate on the 
    // y-axis to be on the bottom side of the image, but image susually have 0.0 at the top of the y-axis.

    FreeImage_FlipVertical(bitmapImage);

    // How many bits-per-pixel is the source image?
    int bitsPerPixel = FreeImage_GetBPP(bitmapImage);

    //writeln("bitsPerPixel = ", bitsPerPixel);

    GLint  	internalFormat;
    GLint   dataFormat;

    FIBITMAP* bitmap;
    if (bitsPerPixel == 32)
    {
        internalFormat = GL_RGBA;
        dataFormat = GL_BGRA;
        writeln("Source image has ", bitsPerPixel, " bits per pixel. Skipping conversion.");
        //writeAndPause("SHOULD HAVE 24 BIT IMAGE");
        bitmap = bitmapImage;
    }
    else
    {
        internalFormat = GL_RGB;
        //dataFormat = GL_BGR;
        dataFormat = GL_RGB;
        bitmap = bitmapImage;        
        writeln("Source image has ", bitsPerPixel, " bits per pixel");
        //bitmap = FreeImage_ConvertTo32Bits(bitmapImage);
    }

    // Some basic image info - strip it out if you don't care
    width  = FreeImage_GetWidth(bitmap);
    height = FreeImage_GetHeight(bitmap);
    writeln("Image: ", file, " is size: ", width, "x", height, ".");

    GLubyte* textureData = FreeImage_GetBits(bitmap);

    //unsigned char* image = SOIL_load_image(filename.c_str(), &width, &height, 0, SOIL_LOAD_RGB);

    // GetBits Returns a pointer to the data-bits of the bitmap. It is up to you to interpret these bytes
    // correctly, according to the results of FreeImage_GetBPP, FreeImage_GetRedMask,
    // FreeImage_GetGreenMask and FreeImage_GetBlueMask.

    // Construct the texture.
    // Note: The 'Data format' is the format of the image data as provided by the image library. FreeImage decodes images into
    // BGR/BGRA format, but we want to work with it in the more common RGBA format, so we specify the 'Internal format' as such.

    // gamma ? GL_SRGB : GL_RGB  // From modeling Tutorial
    if (gamma == true)
        internalFormat = GL_SRGB;

    glTexImage2D(GL_TEXTURE_2D,    // Type of texture
                 0,                // Mipmap level (0 being the top level i.e. full size) 
                 internalFormat,   // Internal format
                 width,            // Width of the texture
                 height,           // Height of the texture,
                 0,                // Border in pixels
                 dataFormat,       // Data format
                 GL_UNSIGNED_BYTE, // Type of texture data
                 textureData);     // The image data to use for this texture



    //glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, image);
    glGenerateMipmap(GL_TEXTURE_2D);	


    glBindTexture(GL_TEXTURE_2D, 0);
    //SOIL_free_image_data(image);
    return textureID;
}