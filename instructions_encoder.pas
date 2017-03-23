unit instructions_encoder;


interface
uses parser,strutils,sysutils;
type
	bin_ptr=^bin;
	bin= record
		code:ShortString;
		next:bin_ptr;
	end;

	{
	pointer_to_list_element = ^list_element;
        
	list_element = record
                string_number:longint; 
                code:ShortString;
                next:pointer_to_list_element;
        end;}

function list_to_bin(mnemonics:pointer_to_list_element):bin_ptr;

implementation


function encode_a_instruction(instruction:ShortString):ShortString;
var
	int_val:longint;
	
begin
	{instruction[1]:='';}
	int_val:=StrToInt(instruction[2..length(instruction)]);
	encode_a_instruction:=IntToBin(int_val,16);
end;

function encode_dest_bits(letters:ShortString):ShortString;
var
	i:integer;
	a,b,c:ShortString;
	
	
begin
	{if length(letters>3) then writeln('Error: too many destinations=)');}
	a:='0';
	b:='0';
	c:='0';
	
	for i:=1 to length(letters) do
	begin
		if letters[i]= 'A' then a:='1';
		if letters[i]= 'D' then b:='1';
		if letters[i]= 'M' then c:='1';
	end;
	encode_dest_bits:=a+b+c;
end;

function encode_jump_bits(letters:ShortString):ShortString;
var
	a,b,c:shortString;
	i:integer;
	
begin
	a:='0';
	b:='0';
	c:='0';
	for i:=1 to length(letters) do
	begin
		if letters[i]='G' then c:='1';
		if (letters[i]='E') and (letters[i-1]<>'N')  then b:='1';
		if letters[i]='L' then a:='1';	
		if letters[i]='M' then 
			begin
				a:='1';
				b:='1';
				c:='1';
			end;
		if letters[i]='N' then 
			begin
				a:='1';	
				b:='0';
				c:='1';	
			end;
	end;
	encode_jump_bits:=a+b+c;
end;

function encode_comp_bits(m:ShortString):ShortString;{Vrry painfull function}
var
	i:integer;
	a,cmpbts:ShortString;
	
begin
	{$IFDEF DEBUG}
		writeln('Code_mnemonics= ',m);
	{$ENDIF}
	for i:=1 to length(m) do
	begin
		if m[i]='M' then 
			begin 
				a:='1';
				break;
			end
			 else a:='0';
	end;
	if m='0' then cmpbts:= '101010';
        if m='1' then cmpbts:= '111111';
        if m='-1' then cmpbts:= '111010';
        if m='D' then cmpbts:= '001100';
        if (m='A') or (m='M') then cmpbts:= '110000';
        if m='!D' then cmpbts:= '001101';
        if (m='!A') or (m='!M') then cmpbts:= '110001';
        if m='-D' then cmpbts:= '001111';
        if (m='-A')  or (m='-M') then cmpbts:= '110011';
	if (m='D-1')  then cmpbts:='001110';
	if (m='A-1') or (m='M-1') then cmpbts:= '110010';
        if (m='D+1') or (m='1+D') then cmpbts:= '011111';
        if (m='A+1') or (m='M+1') or (m='1+A') or (m='1+M') then cmpbts:= '110111';
        if (m='D+A') or (m='D+M') or (m='A+D') or (m='M+D') then cmpbts:= '000010';
        if (m='D-A') or (m='D-M') then cmpbts:= '010011';
        if (m='A-D') or (m='M-D') then cmpbts:= '000111';
        if (m='D&A') or (m='D&M') or (m='A&D') or (m='M&D') then cmpbts:= '000000';
        if (m='D|A') or (m='D|M') or (m='A|D') or (m='M|D') then cmpbts:= '010101';

	encode_comp_bits:= a+cmpbts;
end;


function encode_c_instruction(instruction:ShortString):ShortString;
var
	dest,cmp,jump,comp_part:ShortString;
	start_of_comp,end_of_comp,i:integer;
begin
	start_of_comp:=1;
	end_of_comp:=length(instruction);
	dest:='000';
	cmp:='0000000';
	jump:='000';
	for i:=1 to length(instruction) do
	begin
		if instruction[i]='=' then
		begin
			dest:=copy(instruction,1,i-1);
			dest:=encode_dest_bits(dest);
			start_of_comp:=i+1;
		end;
		if instruction[i]=';' then
		begin
			jump:=copy(instruction,i+1,length(instruction));
			jump:=encode_jump_bits(jump);
			end_of_comp:=i-1;
		end;
	end;
	comp_part:=copy(instruction,start_of_comp,end_of_comp);
	cmp:=encode_comp_bits(comp_part);
	encode_c_instruction:='111'+cmp+dest+jump;
end;

function mnemonics_to_binary(mnemonic:ShortString)
					:ShortString;

begin
	{$IFDEF DEBUG}
		writeln('Mnemonics = ',mnemonic);
	{$ENDIF}
	if mnemonic[1]='@' then
	begin
		mnemonics_to_binary:=encode_a_instruction(mnemonic);
	end
	else
	begin
		mnemonics_to_binary:=encode_c_instruction(mnemonic);
	end;
end;

function list_to_bin(mnemonics:pointer_to_list_element):bin_ptr;
var
	code:ShortString;
	tmp:pointer_to_list_element;
	tmp1:bin_ptr;
	first:bin_ptr;
	current:bin_ptr;
	i:integer;
begin
	{code:=mnemonics^.code;}
	tmp:=mnemonics;
	i:=0;
	new(tmp1);
	while tmp^.code<>'end of code' do
	begin
		i:=i+1;
		code:=tmp^.code;
		tmp1^.code:=mnemonics_to_binary(code);
		if i=1 then 
		begin
			first:=tmp1;
		end;
		
		tmp:=tmp^.next;
		current:=tmp1;
		
		new(tmp1);
		tmp1^.code:='end of code';
		current^.next:=tmp1;
	end;
	list_to_bin:=first;	
end;


{$IFDEF DEBUG}
var
	file_name:ShortString;
	mnemonics:pointer_to_list_element;	
	res,tmp1:bin_ptr;
	f2:text;

{$ENDIF}

begin
	
	{$IFDEF DEBUG}
		writeln(paramstr(1));	
	file_name:=paramstr(1);
		writeln(file_name);
		writeln(length(file_name));
	
			{Name of source code file is passed by command line }
	{new(mnemonics);}
		writeln('DEBUG: NOW WE WILL READ THE FILE');
	mnemonics:=parse_file(file_name);
		writeln('DEBUG: OK, NO PROBLEM HERE ');
	
	res:=list_to_bin(mnemonics);
	tmp1:=res;
	while (tmp1^.code<>'end od code') and assigned(tmp1^.next) do
	begin
		writeln(tmp1^.code);	
		tmp1:=tmp1^.next;
	end;
	file_name:=file_name+'.hack';
	assign(f2,file_name);
	rewrite(f2);
	while res^.code<>'end of code' do
	begin
		
		writeln(f2,res^.code);
		
		res:=res^.next;
	end;
	close(f2);
	{$ENDIF}
end.

