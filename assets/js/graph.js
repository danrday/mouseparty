import * as d3 from "d3";

const Canvas= {
  mounted(){
    d3.select("#graph_canvas").on("mousemove", e => {
      console.log("mousemove", e)
      const transform = d3.zoomTransform(d3.select("#frame_for_zoom").node());
      const xy = d3.pointer(e, "#graph_canvas");
      const xyTransform = transform.invert(xy); // relative to zoom

      const coords = {
          x: xyTransform[0],
          y: xyTransform[1],
          k: transform.k
        }
      this.pushEvent("mouse_move", coords)
    });
  }
}

export default Canvas