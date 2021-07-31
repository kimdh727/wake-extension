import { DefinitionParams, Location, Position, Range } from 'vscode-languageserver/node';
import { ProgramBody, Target, WakeDocument } from "./wake";
import { include } from "./util"

export function definitionHandler(handler: DefinitionParams, doc: WakeDocument): Location | undefined {

  const uri = handler.textDocument.uri;
  const position = handler.position;

  const body = doc.body.filter(body => body.filename == uri);

  body.length == 1 || console.error('Not found file');

  include(body[0].range, position) || console.error('Invalid data');

  const target = getTarget(body[0].body, position);

  if (target)
    return target.targetToLocation();
  else
    return undefined;
}

function getTarget(body: ProgramBody[], p: Position): Target | undefined {

  for (const pb of body) {
    if (include(pb.range, p)) {
      if (pb.body.length) {
        return getTarget(pb.body, p);
      } else if (pb.target) {
        pb.type == 'VarRef' || console.error('Invalid data');
        return pb.target;
      }
    }
  }

  return;
}
