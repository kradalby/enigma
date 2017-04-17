const path = require('path');
const webpack = require('webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin');

const elmLoader = process.env.NODE_ENV === 'development' ? 'elm-hot-loader!elm-webpack-loader?verbose=true&warn=true&debug=true' : 'elm-webpack-loader'

module.exports = {
  entry: {
    app: [
      './src/index.js'
    ]
  },

  output: {
    path: path.resolve(__dirname + '/dist'),
    filename: '[name].js'
  },

  module: {
    rules: [
      {
        test: /\.(css|scss)$/,
        loaders: [
          'style-loader', 'css-loader', 'sass-loader',
        ]
      },
      {
        test: /\.html$/,
        exclude: /node_modules/,
        loader: 'file-loader?name=[name].[ext]'
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader: elmLoader
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'url-loader?limit=10000&mimetype=application/font-woff'
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: 'file-loader'
      },
    ],

    noParse: /\.elm$/
  },

  plugins: process.env.NODE_ENV === 'development' ? [] : [
    new CopyWebpackPlugin([
        { from: 'src/assets/favicons', to: 'favicons' },
    ]),
    new webpack.optimize.UglifyJsPlugin({
      compress: {
        warnings: false,
      },
    })
  ],

  devServer: {
    inline: true,
    stats: { colors: true },
    publicPath: "/enigma"
  }
};
