import { Position, Range } from "vscode-languageserver";

export function include(r: Range, p: Position): boolean {

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
