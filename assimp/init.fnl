(local ffi (require :ffi))
(local {: lib : defs} (require :assimp.lib))
(local {: vec3 : camera} (require :assimp.vecmath))

(local max-colors defs.AI_MAX_NUMBER_OF_COLOR_SETS)
(local max-uvs defs.AI_MAX_NUMBER_OF_TEXTURECOORDS)

(local mesh {:has_positions (fn [self]
                              (and self.mVertices (> self.mNumVertices 0)))
             :has_faces (fn [self]
                          (and self.mFaces (> self.mNumFaces 0)))
             :has_normals (fn [self]
                            (and self.mNormals (> self.mNumVertices 0)))
             :has_tangents_and_bitangents (fn [self]
                                            (and self.mTangets self.mBitangents
                                                 (> self.mNumVertices 0)))
             :has_vertex_colors (fn [self idx]
                                  (let [valid-idx (< idx max-colors)]
                                    (and valid-idx (. self.mColors idx)
                                         (> self.mNumVertices 0))))
             :has_texture_coords (fn [self idx]
                                   (let [valid-idx (< idx max-uvs)]
                                     (and valid-idx (. self.mTextureCoords idx)
                                          (> self.mNumVertices 0))))
             :get_num_uv_channels (fn [self]
                                    (var n 0)
                                    (while (and (< n max-uvs)
                                                (. self.mTextureCoords n))
                                      (set n (+ n 1)))
                                    n)
             :get_num_color_channels (fn [self]
                                       (var n 0)
                                       (while (and (< n max-colors)
                                                   (. self.mColors n))
                                         (set n (+ n 1)))
                                       n)
             :has_bones (fn [self]
                          (and self.mBones (> self.mNumBones 0)))
             :has_texture_coords_name (fn [self idx]
                                        (if (and (= self.mTextureCoordsNames
                                                    nil)
                                                 (> idx max-uvs))
                                            false
                                            (not= (. self.mTextureCoordsNames
                                                     idx)
                                                  nil)))
             :get_texture_coords_name (fn [self idx]
                                        (if (and (= self.mTextureCoordsNames
                                                    nil)
                                                 (> idx max-uvs))
                                            ""
                                            (ffi.string (. self.mTextureCoordsNames
                                                           idx))))})

(local anim-mesh
       {:has_positions (fn [self]
                         (not= self.mVertices nil))
        :has_normals (fn [self]
                       (not= self.mNormals nil))
        :has_tangents_and_bitangents (fn [self]
                                       (not= self.mTangents nil))
        :has_vertex_colors (fn [self idx]
                             (let [valid-idx (< idx max-colors)]
                               (and valid-idx (. self.mColors idx))))
        :has_texture_coords (fn [self idx]
                              (let [valid-idx (< idx max-uvs)]
                                (and valid-idx (. self.mTextureCoords idx))))})

(local texture {:check_format (fn [self str]
                                (let [fmt-str (ffi.string self.achFormatHint)]
                                  (= fmt-str str)))})

;; TODO: GetEmbededTexture, GetEmbededTextureAndIndex
(local scene
       {:get_name (fn [self]
                    (ffi.string self.mName.data self.mName.length))
        :has_meshes (fn [self]
                      (and self.mMeshes (> self.mNumMeshes 0)))
        :has_materials (fn [self]
                         (and self.mMaterials (> self.mNumMaterials 0)))
        :has_lights (fn [self]
                      (and self.mLights (> self.mNumLights 0)))
        :has_textures (fn [self]
                        (and self.mTextures (> self.mNumTextures 0)))
        :has_cameras (fn [self]
                       (and self.mCameras (> self.mNumCameras 0)))
        :has_animations (fn [self]
                          (and self.mAnimations (> self.mNumAnimations 0)))
        :has_skeletons (fn [self]
                         (and self.mSkeletons (> self.mNumSkeletons 0)))})

(local metatypes
       {:vec3 vec3
        :camera camera
        :mesh (ffi.metatype :aiMesh {:__index mesh})
        :anim_mesh (ffi.metatype :aiAnimMesh {:__index anim-mesh})
        :texture (ffi.metatype :aiTexture {:__index texture})
        :scene (ffi.metatype :aiScene {:__index scene})})

(fn import-file [path ?flags wrap]
  (let [scene (lib.aiImportFile path (or ?flags 0))]
    (if (not= scene nil)
        (wrap scene)
        (values nil (ffi.string (lib.aiGetErrorString))))))

{:import_file (λ [path ?flags]
                (import-file path ?flags
                             (fn [scene]
                               scene)))
 :import_file_nogc (λ [path ?flags]
                     (import-file path ?flags
                                  (fn [scene]
                                    (ffi.gc scene lib.aiReleaseImport))))
 :release_import (λ [scene]
                   (lib.aiReleaseImport (ffi.gc scene nil)))
 :_metatypes metatypes}
