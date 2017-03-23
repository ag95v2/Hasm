unit parser;

interface
type 
	pointer_to_list_element = ^list_element;
	list_element = record	
		string_number:longint; {USER NUMBER FOR Debugging }
		code:ShortString;
		next:pointer_to_list_element;
	end;

function parse_file(file_name:ShortString):pointer_to_list_element;

implementation

uses strutils;

procedure debug_print(first:pointer_to_list_element);
var
	tmp:pointer_to_list_element;
begin
	tmp:=first;
	writeln('DEBUG CHECK');
	while  tmp^.code<>'end of code' do
	begin
		write(tmp^.string_number);
		writeln('.',tmp^.code);
		tmp:=tmp^.next;
	end;
end;

function rm_spaces_comments(line_of_code:ShortString):ShortString;
var
	out:ShortString;
	i:integer;
begin
	out:=DelChars(line_of_code,' ');
	out:=DelChars(out,'	');
	out:=DelChars(out,#10); {new line}

	if length(out)>0 then
	begin
		for i:=1 to length(out) do
		begin
			if out[i]='/' then
			begin
				out:=LeftStr(out,i-1);
				break;	
			end;
		end;
	end;

	rm_spaces_comments:=out;
end;
	

function parse_file(file_name:ShortString):pointer_to_list_element;
var
        f1:text;
        first,tmp,current_element:pointer_to_list_element;
        line_counter,commands_counter:longint;
        current_readable_data:ShortString;
	max_line_number:longint;

begin
	{$IFDEF DEBUG}
		writeln('DEBUG: assign');
	{$ENDIF}
	assign(f1,file_name);
	{$IFDEF DEBUG}
		writeln('DEBUG: reset');
	{$ENDIF}
	reset(f1);
	{$IFDEF DEBUG}
		writeln('DEBUG: start parser');
		max_line_number:=40;
	{$ENDIF}
	line_counter:=0;	{Number of string in text file}
	commands_counter:=0;	{Number of commands in text file}
	new(first);
	new(current_element);
	while not SeekEof(f1) do
	begin
		line_counter:=line_counter+1;
		readln(f1,current_readable_data);
		{$IFDEF DEBUG}
			write('DEBUG: ',line_counter, ' lines read; ');
			writeln('current line: ',current_readable_data);
		{$ENDIF}

		current_readable_data:=rm_spaces_comments(current_readable_data);
		if  length(current_readable_data)>0 then 
		begin
			commands_counter:= commands_counter+1;
			{$IFDEF DEBUG}
				if commands_counter>max_line_number then break;
			{$ENDIF}
			if commands_counter=1 then 
			begin 
				first^.code:=current_readable_data;
				first^.string_number:=line_counter;
				new(tmp);
				tmp^.code:='end of code';
				first^.next:=tmp;
			end
			else
			begin
				current_element:=tmp;
				current_element^.code:=current_readable_data;
				current_element^.string_number:=line_counter;
				new(tmp);	
				tmp^.code:='end of code';
				current_element^.next:=tmp;
			end;
		end;
	end;
	write('Code successfully parsed: ');
	write(line_counter);
	writeln(' lines found in file');
	{$IFDEF DEBUG}
		debug_print(first);	
	{$ENDIF}	
	close(f1);
	parse_file:=first;
end;
begin

end.
