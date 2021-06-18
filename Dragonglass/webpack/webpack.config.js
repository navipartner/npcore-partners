const path = require("path");
// const BundleAnalyzerPlugin = require("webpack-bundle-analyzer")
//   .BundleAnalyzerPlugin;
var CaseSensitivePathsPlugin = require("case-sensitive-paths-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");

// https://webpack.js.org/plugins/mini-css-extract-plugin/#extracting-css-based-on-entry
function recursiveIssuer(m, c) {
  const issuer = c.moduleGraph.getIssuer(m);
  // For webpack@4 chunks = m.issuer

  if (issuer) {
    return recursiveIssuer(issuer, c);
  }

  const chunks = c.chunkGraph.getModuleChunks(m);
  // For webpack@4 chunks = m._chunks

  for (const chunk of chunks) {
    return chunk.name;
  }

  return false;
}

// Each theme SCSS file needs to be added to entry and optimization/splitChunks/cacheGroups
module.exports = {
  entry: {
    bundle: "./packages/dragonglass-react/src/index.js",
    themeDark: "./packages/dragonglass-react/src/styles/themes/dark.scss",
    themeLight: "./packages/dragonglass-react/src/styles/themes/light.scss",
    themeFresh: "./packages/dragonglass-react/src/styles/themes/fresh.scss",
    themeDefault: "./packages/dragonglass-react/src/styles/themes/default.scss",
  },
  mode: "development",
  module: {
    rules: [
      {
        test: /\.js$/,
        enforce: "pre",
        use: ["source-map-loader"],
      },
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: ["babel-loader"],
      },
      {
        test: /\.(css|scss)$/,
        use: [MiniCssExtractPlugin.loader, "css-loader", "sass-loader"],
      },
    ],
  },
  optimization: {
    splitChunks: {
      cacheGroups: {
        bundleStyles: {
          name: "styles_bundle",
          test: (m, c, entry = "bundle") =>
            m.constructor.name === "ScssModule" &&
            recursiveIssuer(m, c) === entry,
          chunks: "all",
          enforce: true,
        },
        themeDarkStyles: {
          name: "styles_dark_theme",
          test: (m, c, entry = "themeDark") =>
            m.constructor.name === "ScssModule" &&
            recursiveIssuer(m, c) === entry,
          chunks: "all",
          enforce: true,
        },
        themeLightStyles: {
          name: "styles_light_theme",
          test: (m, c, entry = "themeLight") =>
            m.constructor.name === "ScssModule" &&
            recursiveIssuer(m, c) === entry,
          chunks: "all",
          enforce: true,
        },
        themeLightStyles: {
          name: "styles_fresh_theme",
          test: (m, c, entry = "themeFresh") =>
            m.constructor.name === "ScssModule" &&
            recursiveIssuer(m, c) === entry,
          chunks: "all",
          enforce: true,
        },
        themeLightStyles: {
          name: "styles_default_theme",
          test: (m, c, entry = "themeDefault") =>
            m.constructor.name === "ScssModule" &&
            recursiveIssuer(m, c) === entry,
          chunks: "all",
          enforce: true,
        },
      },
    },
  },
  plugins: [
    new CaseSensitivePathsPlugin(),
    new MiniCssExtractPlugin({
      filename: "[name].css",
    }),
    new CleanWebpackPlugin(),
    // new BundleAnalyzerPlugin(), // Uncomment this line if you want to run package analyzer
  ],
  output: {
    path: path.resolve(__dirname, "dist/"),
    publicPath: "/dist/",
    filename: "[name].js",
  },
  devServer: {
    contentBase: path.join(__dirname, "public/"),
    port: 3000,
    disableHostCheck: true,
    host: "0.0.0.0",
    publicPath: "http://localhost:3000/dist/",
    hotOnly: true,
  },
  devtool: "source-maps",
};
