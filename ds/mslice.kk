module ds/mslice
import ds/matrix

// Shared slice of a `matrix`.
abstract struct mslice<h, a>
  mat : ref<h, matrix<a>>
  top : int
  left : int
  pub rows : int
  pub cols : int
  check : bool

pub fun matrix/mslice(mat : matrix<_>)
  ref(mat).mslice

pub fun refmatrix/mslice(mat : ref<_,matrix<_>>)
  Mslice(mat, 0, 0, (!mat).rows, (!mat).cols, True)

pub fun size(mslice : mslice<_, _>) : (int, int)
  (mslice.rows, mslice.cols)

pub fun offset(mslice : mslice<_, _>) : (int, int)
  (mslice.top, mslice.left)

/* Access the backing matrix if this is a full slice.
 * Throws an exception if this slice is checked and not a full slice of the
 * backing matrix.
 */
pub fun full(mslice : mslice<h, a>) : <pure,read<h>> ref<h, matrix<a>>
  val Mslice(mat, t, l, r, c, check) = mslice
  if !check || (t == 0 && l == 0 && r == (!mat).rows && c == (!mat).cols) then
    mat
  else
    throw("Tried to access backing matrix of `mslice` without having a full slice.")

pub fun check-bounds(mslice : mslice<_, _>, top : int, left : int, rows : int, cols : int) : bool
  val Mslice(_, _, _, r, c, check) = mslice
  !check || (top >= 0 && left >= 0 && rows >= 0 && cols >= 0 && top + rows <= r && left + cols <= c)

pub fun valid-idx(mslice : mslice<_, _>, idx : idx) : bool
  val (i, j) = idx
  !mslice.check || (i >= 0 && j >= 0 && i < mslice.rows && j < mslice.cols)

pub fun assert-valid-idx(mslice, idx) : exn ()
  if !mslice.valid-idx(idx) then
    throw("Index " ++ show(idx) ++ " out of bounds " ++ show(mslice.size))


pub fun mslice/slice(mslice : mslice<_, _>, top : int = 0, left : int = 0, rows : int = mslice.rows - top, cols : int = mslice.cols - left) : _ maybe<mslice<_, _>>
  if !mslice.check-bounds(top, left, rows, cols) then
    Nothing
  else
    val Mslice(mat, t, l, _, _, check) = mslice
    Just(Mslice(mat, t + top, l + left, rows, cols, check))

/* Disables slice bounds checking for this slice.
   This allows slices to be used as an offset, for example in a GUI.
 */
pub fun unchecked(mslice : mslice<_, _>) : mslice<_, _>
  mslice(check = False)
  
pub fun checked(mslice : mslice<_, _>) : mslice<_, _>
  mslice(check = True)

pub fun @index(mslice : mslice<h, a>, idx : idx) : <read<h>,pure> a
  mslice.assert-valid-idx(idx)
  (!mslice.mat)[idx + mslice.offset]

pub fun assign/@index(mslice : mslice<h, a>, idx : idx, assigned : a) : <read<h>,write<h>,pure> ()
  mslice.assert-valid-idx(idx)
  mslice.mat[idx + mslice.offset] := assigned
