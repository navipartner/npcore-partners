import builtinSaleline from "./builtin-saleline";

const providers = {
  BUILTIN_SALELINE: builtinSaleline,
};

export const ConfigProvider = {
  getLayout: (setup) => {
    if (providers[setup.dataSource]) {
      const provider = providers[setup.dataSource];
      if (!provider) {
        return null;
      }

      return provider.mobile || provider;
    }

    // here be dragons, for now
  },
  getButtons: (setup) => {
    //
  },
};
