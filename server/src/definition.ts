import { DefinitionParams, Location, Position, Range } from 'vscode-languageserver/node';
import { ProgramBody, Target, WakeDocument } from "./wake";

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

function include(r: Range, p: Position): boolean {

  const startLine = r.start.line;
  const startCharacter = r.start.character;
  const endLine = r.end.line;
  const endCharacter = r.end.character;

  const line = p.line
  const character = p.character

  if (startLine <= line && line <= endLine) {
    if (startLine == line && endLine == line) {
      if (startCharacter <= character && character <= endCharacter)
        return true;
      else
        return false;
    } else if (startLine == line) {
      if (startCharacter <= character)
        return true;
      else
        return false;
    } else if (endLine == line) {
      if (endCharacter >= character)
        return true;
      else
        return false;
    } else {
      return true;
    }
  } else {
    return false;
  }
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
