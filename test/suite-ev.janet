# Copyright (c) 2025 Calvin Rose & contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

(import ./helper :prefix "" :exit true)
(start-suite)

# Deadline with interrupt
(defmacro with-deadline2
  ``
  Create a fiber to execute `body`, schedule the event loop to cancel
  the task (root fiber) associated with `body`'s fiber, and start
  `body`'s fiber by resuming it.

  The event loop will try to cancel the root fiber if `body`'s fiber
  has not completed after at least `sec` seconds.

  `sec` is a number that can have a fractional part.
  ``
  [sec & body]
  (with-syms [f]
    ~(let [,f (coro ,;body)]
       (,ev/deadline ,sec nil ,f true)
       (,resume ,f))))

(eprint "---")

(for i 0 10
  (print "deadline 1 iteration " i)
  (assert (= :done (with-deadline2 10
                     (ev/sleep 0.01)
                     :done)) "deadline with interrupt exits normally"))

(eprint "---")

(for i 0 10
  (print "deadline 2 iteration " i)
  (let [f (coro (forever :foo))]
    (ev/deadline 0.01 nil f true)
    (assert-error "deadline expired" (resume f))))

(end-suite)
