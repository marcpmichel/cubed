
	// use gl.Func(args) instead of glFunc(args)

  struct gl {
     static auto ref opDispatch(string name, Args...)(Args args) {
        scope (exit) checkGLError();
        return mixin("gl"~name~"(args)");
     }
  }
