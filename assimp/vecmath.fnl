(local ffi (require :ffi))

(fn vec3-normalize! [vec]
  (let [xx (* vec.x vec.x)
        yy (* vec.y vec.y)
        zz (* vec.z vec.z)
        len (math.sqrt (+ xx yy zz))]
    (when (> len 0)
      (set vec.x (/ vec.x len))
      (set vec.y (/ vec.y len))
      (set vec.z (/ vec.z len)))))

(fn vec3-cross [a b]
  (let [vec (ffi.new "aiVector3D[1]")
        x (- (* a.y b.z) (* a.z b.y))
        y (- (* a.z b.x) (* a.x b.z))
        z (- (* a.x b.y) (* a.y b.x))]
    (set vec.x x)
    (set vec.y y)
    (set vec.z z)
    vec))

(fn vec3-dot [a b]
  (let [x (* a.x b.x)
        y (* a.y b.y)
        z (* a.z b.z)]
    (+ x y z)))

(local vector3d {:normalize (fn [self]
                              (let [vec (ffi.new "aiVector3D[1]")]
                                (ffi.copy vec self (ffi.sizeof :aiVector3D))
                                (vec3-normalize! vec)
                                vec))})

(fn cam-build-matrix [up look-at pos]
  (let [mat (ffi.new "aiMatrix4x4[1]")
        zaxis (look-at:normalize)
        yaxis (up:normalize)
        xaxis-cross (vec3-cross up look-at)
        xaxis (xaxis-cross:normalize)]
    (set mat.a4 (- (vec3-dot xaxis pos)))
    (set mat.b4 (- (vec3-dot yaxis pos)))
    (set mat.c4 (- (vec3-dot zaxis pos)))
    (set mat.a1 xaxis.x)
    (set mat.a2 xaxis.y)
    (set mat.a3 xaxis.z)
    (set mat.b1 yaxis.x)
    (set mat.b2 yaxis.y)
    (set mat.b3 yaxis.z)
    (set mat.c1 zaxis.x)
    (set mat.c2 zaxis.y)
    (set mat.c3 zaxis.z)
    (set mat.d1 0)
    (set mat.d2 0)
    (set mat.d3 0)
    (set mat.d4 1)))

(local camera
       {:get_camera_matrix (fn [self]
                             (cam-build-matrix self.mUp self.mLookAt
                                               self.mPosition))})

{:vec3 (ffi.metatype :aiVector3D {:__index vector3d})
 :camera (ffi.metatype :aiCamera {:__index camera})}
