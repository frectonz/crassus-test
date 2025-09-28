declare module "*.elm" {
  interface ElmApp {
    init(options: { node?: HTMLElement | null; flags?: unknown }): unknown;
  }

  const elmModule: ElmApp;

  export default elmModule;
}
