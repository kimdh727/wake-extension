import { spawnSync } from "child_process";
import { pathToFileURL } from "url";
import { Range, Location } from "vscode-languageserver";

export class WakeDocument {
  readonly type: string = "Workspace";
  body: WorkspaceBody[] = [];
}

export interface HasProgramBody {
  type: string;
  body: ProgramBody[];
  range: Range;
}

export class Target {
  readonly filename: string;
  range: Range;

  constructor(filename: string, range: Range) {
    this.filename = filename;
    this.range = range;
  }

  targetToLocation(): Location {
    return Location.create(this.filename, this.range);
  }
}

export class ProgramBody implements HasProgramBody {
  type: string;
  range: Range;
  sourceType: string;
  target?: Target
  body: ProgramBody[] = [];

  constructor(type: string, range: Range, sourceType: string, target?: Target) {
    this.type = type;
    this.range = range;
    this.sourceType = sourceType;
    this.target = target;
  }
}

export class WorkspaceBody implements HasProgramBody {
  readonly type: string = "Program";
  filename: string;
  range: Range;
  source: string[];
  body: ProgramBody[] = [];

  constructor(filename: string, range: Range, source: string[]) {
    this.filename = filename;
    this.range = range;
    this.source = source
  }
}

export function sourceToRange(source: string[], start: number, end: number): Range {
  end -= start;

  let startLine = 0;
  let startCharacter = 0;
  let endLine = 0;
  let endCharacter = 0;

  for (let i = 0; i < source.length; i++) {
    if (start - (Buffer.byteLength(source[i], 'utf-8') + 1) >= 0) {
      start -= Buffer.byteLength(source[i], 'utf-8') + 1;
      startLine++;
    } else {
      break;
    }
  }

  startCharacter = start - (Buffer.byteLength(source[startLine], 'utf-8') - source[startLine].length);

  for (let i = startLine; i < source.length; i++) {
    if (start + end - (Buffer.byteLength(source[i], 'utf-8') + 1) >= 0) {
      end -= Buffer.byteLength(source[i], 'utf-8') + 1;
      endLine ++;
    } else {
      break;
    }
  }

  endLine += startLine;
  endCharacter = start + end - (Buffer.byteLength(source[endLine], 'utf-8') - source[endLine].length);

  return Range.create(startLine, startCharacter, endLine, endCharacter);
}

export function runWakeHtml(): any {
  const wakeHtml = spawnSync('wake', ['--html'], { maxBuffer: 0 });
	const err = wakeHtml.stderr.toString();
	let out = wakeHtml.stdout.toString();

	if (err.includes('>>> Aborting without execution <<<') ||
      !out.includes('<script type="wake">')) {
		console.error(err);
		return;
	}

	out = out.slice(out.indexOf('<script type="wake">'));
	out = out.replace('<script type="wake">', '');
	out = out.replace('</script>', '');

  const json = JSON.parse(out);

  json.type == 'Workspace' || console.error('Invalid data');

  return json
}

export function htmlToWakeDocument(json: any, doc: WakeDocument): WakeDocument {

  for (const wsb of json.body) {
		wsb.type == 'Program' || console.error('Invalid data');
		const filename = pathToFileURL(wsb.filename).href

		const source: string[] = wsb.source.split(RegExp('\\n'));

    let index = doc.body.findIndex(body => body.filename == filename)

    // TODO: TARGET UPDATE
    // if (index != -1 && doc.body[index].source.toString() == source.toString()) {
    // } else {
    // }

    let range = sourceToRange(source, wsb.range[0], wsb.range[1])
    let wb = new WorkspaceBody(filename, range, source);

    htmlToProgramBody(json, wsb.body, wb, source);

    if (index != -1) {
      doc.body[index] = wb;
    } else {
      doc.body.push(wb);
    }
	}

  return doc
}

export function htmlToProgramBody(json: any, jsonbody: any, body: HasProgramBody, source: string[]): void {

  for (const pb of jsonbody) {
    const type = pb.type;
    const range = sourceToRange(source, pb.range[0], pb.range[1]);
    const sourceType = pb.sourceType;
    let target;
    if (pb.target) {
      type == 'VarRef' || console.error('Invalid data');

      const t = pb.target;
      const filename = pathToFileURL(t.filename).href;
      const range = sourceToRange(htmlToSource(json, t.filename), t.range[0], t.range[1]);
      target = new Target(filename, range);
    }

    const index = body.body.push(new ProgramBody(type, range, sourceType, target));

    if (pb.body) htmlToProgramBody(json, pb.body, body.body[index - 1], source);
  }
}

export function htmlToSource(json: any, url: string): string[] {

  let result = json.body.filter( (body: { filename: string; }) => body.filename == url )

  if (result.length != 1)
    console.error("DO NOT REACH");

  return result[0].source.split(RegExp('\\n'));
}
