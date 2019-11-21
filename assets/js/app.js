
// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "bootstrap"
import "phoenix_html"
import CodeMirror from "codemirror"
import "codemirror/mode/pascal/pascal.js"
import $ from "jquery"


// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

let cm = null;

$(document).ready(() => {
  let sourceCode = document.getElementById("sourceCode");
  cm = CodeMirror.fromTextArea(sourceCode, {lineNumbers: true, mode: "text/x-pascal"});
  $("#parseButton").click(doParse);
});

function doParse() {
  let code = cm.getValue().trim();
  let resultPane = $("#result");
  resultPane.removeClass("border-danger");
  resultPane.children(".card-header").removeClass("bg-danger text-white").text("Parsing...");
  $("#resultCode").text("");
  resultPane.show();
  $.ajax({
    method: "POST",
    url: "./api/parse",
    data: {
      while_code: code,
      as_text: true,
      pretty: true
    },
    success: (data, status, jqXHR) => {
      if (data.ok) {
        resultPane.children(".card-header").text("Result")
        $("#resultCode").text(data.body);
      } else if (data.line_no && data.msg) {        
        resultPane.addClass("border-danger");
        resultPane.children(".card-header").addClass("bg-danger text-white").text(`Error: line ${data.line_no}`);
        $("#resultCode").text(data.msg);
      } else {
        resultPane.addClass("border-danger");
        resultPane.children(".card-header").addClass("bg-danger text-white").text(`Unexpected error`);
        console.error(data);
      }
    },
    error: (_jqXHR, status, errorThrown) => {
      resultPane.addClass("border-danger");
      resultPane.children(".card-header").addClass("bg-danger text-white").text(`Unexpected error`);
      console.error(status);
      console.error(errorThrown);
    }
  });
}