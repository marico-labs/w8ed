const path = require("path");
const CracoAlias = require("craco-alias");
const { pathsToModuleNameMapper } = require("ts-jest");
const { compilerOptions } = require("./tsconfig.paths.json");

module.exports = {
  webpack: {
    // now using tsconfig.paths.json instead of alias from craco
    // alias: {
    //   "@components": path.resolve(__dirname, "src/components/"),
    //   "@pages": path.resolve(__dirname, "src/pages/")
    //   "@hooks": path.resolve(__dirname, "src/hooks/")
    // }
  },
  jest: {
    configure: {
      preset: 'ts-jest',
      moduleNameMapper: pathsToModuleNameMapper(compilerOptions.paths, {
        prefix: '<rootDir>/src/'
      })
    }
  },
  style: {
    postcssOptions: {
      plugins: [
        require('autoprefixer')
      ]
    }
  },
  plugins: [
    {
      plugin: CracoAlias,
      options: {
        baseUrl: "./src",
        source: "tsconfig",
        tsConfigPath: "./tsconfig.paths.json",
        // debug: true
      }
    }
  ]
}