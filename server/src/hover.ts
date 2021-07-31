import { Hover, HoverParams, Position } from "vscode-languageserver";
import { include } from "./util";
import { ProgramBody, WakeDocument } from "./wake";

export function hoverHandler(handler: HoverParams, doc: WakeDocument): Hover | undefined {

  const uri = handler.textDocument.uri;
  const position = handler.position;

  const body = doc.body.filter(body => body.filename == uri);

  body.length == 1 || console.error('Not found file');

  include(body[0].range, position) || console.error('Invalid data');

  const pb = getBody(body[0].body, position)

  const hover = pb ? { contents: pb.type + ": " + pb.sourceType, range: pb.range } : undefined;

  if (Hover.is(hover))
    return hover;
  else
    return undefined;
}

function getBody(body: ProgramBody[], p: Position): ProgramBody | undefined {

  for (const pb of body) {
    if (include(pb.range, p)) {
      if (pb.body.length) {
        return getBody(pb.body, p);
      } else if (pb.target) {
        return pb;
      }
    }
  }

  return;
}
