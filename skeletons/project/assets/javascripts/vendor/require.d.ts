declare module require {
    export function (config:any, requires: string[], f: Function);
    export function (requires: string[], f: Function);
    export function (requires: string);
    export function config(require: any);
};

declare module requirejs {
    export function (config:any, requires: string[], f: Function);
    export function (requires: string[], f: Function);
    export function (requires: string);
    export function config(require: any);
};

declare module define {
    export function (dependencies: string[], f: Function);
    export function (f: Function);
};