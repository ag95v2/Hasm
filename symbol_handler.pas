unit symbol_handler;


interface

uses sysutils,strutils,parser;

function handle_symbols(code:pointer_to_list_element)
			:pointer_to_list_element;

implementation

{uses sysutils,strutils,parser;}


type	
	symbol_table_ptr = ^symbol_table;
	symbol_table = record
		symbol:shortstring;
		value:ShortString;
		next:symbol_table_ptr;
	end;
	table_meta = record
		min_var_address:integer;
		first,last:symbol_table_ptr;
	end;
	parsed_labels = record
		txt:pointer_to_list_element;
		lbls:table_meta;
	end;
	symbol_info = record
		is_in_table:boolean;
		value:ShortString;
	end;
	final_table = record
		table:symbol_table_ptr;
		code:pointer_to_list_element;
	end;


function init_table():table_meta;{Pre-defined symbols}

var
	first,tmp,current:symbol_table_ptr;
	i:integer;
	tbl:table_meta;
begin
	new(first);
	current:=first;
	current^.symbol:='R0';
	current^.value:='0';new(tmp);current^.next:=tmp;current:=tmp; 
	
	current^.symbol:='R1';
	 current^.value:='1'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R2';
	 current^.value:='2'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R3';
	 current^.value:='3'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R4';
	 current^.value:='4'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R5';
	 current^.value:='5'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R6';
	 current^.value:='6'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R7';
	 current^.value:='7'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R8';
	 current^.value:='8'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R9';
	 current^.value:='9'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R10';
	 current^.value:='10'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R11';
	 current^.value:='11'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R12';
	 current^.value:='12'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R13';
	 current^.value:='13'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R14';
	 current^.value:='14'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='R15';
	 current^.value:='15'; new(tmp); current^.next:=tmp; current:=tmp;


	current^.symbol:='SCREEN';
	 current^.value:='16384'; new(tmp); current^.next:=tmp; current:=tmp;
	
	current^.symbol:='KBD';
	 current^.value:='24576'; new(tmp); current^.next:=tmp; current:=tmp;


	current^.symbol:='SP';
	 current^.value:='0'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='LCL';
	 current^.value:='1'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='ARG';
	 current^.value:='2'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='THIS';
	 current^.value:='3'; new(tmp); current^.next:=tmp; current:=tmp;
	current^.symbol:='THAT';
	 current^.value:='4'; new(tmp); current^.next:=tmp; current:=tmp;
	tbl.first:=first;
	tbl.last:=current; {NOT assigned yet}
	tbl.min_var_address:=16;
	init_table:=tbl;
	{$IFDEF DEBUG}
	i:=0;
	current:=first;
	while current^.next<>nil do
	begin
		i:=i+1;
		writeln(i,'.',current^.symbol,': ', current^.value);	
		current:=current^.next;
	end;

	{$ENDIF}
end;

function add_label(table:table_meta;
			lbl:ShortString;
			value:ShortString):table_meta;

var 
	tmp:symbol_table_ptr;
	
begin
	new(tmp);
	table.last^.value:=value;
	table.last^.symbol:=lbl;
	table.last^.next:=tmp;
	table.last:=tmp;
	add_label:=table;
end;

function add_variable(table:table_meta;variable:ShortString):table_meta;

var
	value,symbol:ShortString;
	min_address:integer;

begin
	min_address:=table.min_var_address;
	value:=IntToStr(min_address);
	table:=add_label(table,variable,value);
	table.min_var_address:=table.min_var_address+1;
	add_variable:=table;
end;

procedure print_table(table:table_meta);
var
	current,last:symbol_table_ptr;
	i:integer;
begin
	current:=table.first;
	i:=0;
	while current^.next<>nil do
	begin
		i:=i+1;
		writeln(i,'.',current^.symbol,': ', current^.value);	
		current:=current^.next;
	end;
end;


function parse_labels(txt:pointer_to_list_element;table:table_meta):
					parsed_labels;
var
	i,crnt_lbl_int:integer;
	first,current,prev:pointer_to_list_element;
	crnt_lbl:ShortString;
	crnt_val:ShortString;
	res:parsed_labels;
	counter:integer;
begin
	i:=0;	
	current:=txt;
	first:=current;
	new(prev);
	prev:=nil;
	{$IFDEF DEBUG}writeln(prev=nil);{$ENDIF}
	while current^.next<>nil do
	begin
		{$IFDEF DEBUG}
			writeln('i++',i,': ',current^.code);
			counter:=counter+1;
			{if counter>8 then break;}
		{$ENDIF}
		i:=i+1;
		
		if current^.code[1]='(' then
		begin
			{$IFDEF DEBUG}
				writeln('Label found',' prev<>nil:',prev<>nil);
			{$ENDIF}
			crnt_lbl:=current^.code;
			crnt_lbl:=MidStr(crnt_lbl,2,length(crnt_lbl)-2);
			crnt_val:=IntToStr(i-1);{RUNTIME BUG DETECTED HERE}
			i:=i-1;	
			table:=add_label(table, crnt_lbl, crnt_val);
			
			if prev<>nil then {remove current element from list}
			begin
				prev^.next:=current^.next;	
				dispose(current);
				current:=prev^.next;
				{$IFDEF DEBUG}
					writeln('precvious= ',
						prev^.code,
						'current= ', 
						current^.code,
						' List element removed');
				{$ENDIF}

			end
			else
			begin
				if i=1 then 
				begin
					first:=current^.next;
					dispose(current);
					current:=first;
					{$IFDEF DEBUG}
						writeln('First element removed');
					{$ENDIF}
				end;	
			end;
		end
		else
		begin
			if  i=1 then
			begin
				first:=current;
				prev:=nil;	
				current:=current^.next;
			end
			else
			begin
				prev:=current;
				current:=current^.next;
			end;
		end;
	end;
	res.txt:=first;	
	res.lbls:=table;
	parse_labels:=res;
	
end;

procedure add_list_element(list:pointer_to_list_element;value:ShortString);
var
	last,tmp:pointer_to_list_element;
begin
	last:=list;
	while last^.next<>nil do 
	begin
		last:=last^.next;
	end;
	new(tmp);
	tmp^.code:=value;
	last^.next:=tmp;
	
end;


function init_list():pointer_to_list_element;
var
	first:pointer_to_list_element;
begin
	new(first);
	first^.code:='@loop0';
	add_list_element(first,'@R0');
	add_list_element(first,'(loop0)');
	add_list_element(first,'@V0');
	add_list_element(first,'@R1');
	add_list_element(first,'(loop1)');
	add_list_element(first,'@V1');
	add_list_element(first,'@R0');
	add_list_element(first,'(loop2)');
	add_list_element(first,'@loop2');

	add_list_element(first,'@V2');
	add_list_element(first,'@V3');
	add_list_element(first,'@V4');
	init_list:=first;
end;

procedure print_list(list:pointer_to_list_element);
var
	current:pointer_to_list_element;
begin
	current:=list;
	repeat
		writeln(current^.code);
		current:=current^.next;
	until current=nil;
end;

function find_symbol(table:table_meta;symbol:ShortString):symbol_info;
	{Linear searach}
var
	info:symbol_info;
	current:symbol_table_ptr;

begin
	current:=table.first;
	while current<>nil do
	begin
		if current^.symbol=symbol then 
		begin
			info.is_in_table:=true;
			info.value:=current^.value;
			break;
		end
		else
		info.is_in_table:=false;
		info.value:='not found';
		current:=current^.next;
	end;
	find_symbol:=info;
end;

function parse_variables(list:pointer_to_list_element;
			 tbl:table_meta):final_table;

var
	current:pointer_to_list_element;
	txt:ShortString;
	inf:symbol_info;
	res:final_table;
begin
	current:=list;
	while current<>nil do
	begin
		if current^.code[1]='@' then
		begin
			txt:=MidStr(current^.code,2,length(current^.code));
			if (ord(txt[1])<58) and (ord(txt[1])>47) then
			begin
				current:=current^.next;	
						{VARS DO NOT START WITH NUMBERS}
			end
			else
			begin
				inf:=find_symbol(tbl,txt);
				if inf.is_in_table=true then
				begin
					{$IFDEF DEBUG}
						writeln('label found: ',txt); 
					{$ENDIF}
					txt:=inf.value;
					current^.code:='@'+txt;
				end
				else
				begin
					tbl:=add_variable(tbl,txt);
					{$IFDEF DEBUG}
						writeln('variable added: ',txt); 
					{$ENDIF}
					inf:=find_symbol(tbl,txt);
					txt:=inf.value;
					current^.code:='@'+txt;
						
				end;
			end;
		end;
	
		current:=current^.next;
	end;
	res.table:=tbl.first;
	res.code:=list;
	parse_variables:=res;
end;

function handle_symbols(code:pointer_to_list_element)
			:pointer_to_list_element;
var
	table:table_meta;
	prsd_lbls:parsed_labels;
	final:final_table;


begin
	table:=init_table();
	prsd_lbls:=parse_labels(code,table);
	code:=prsd_lbls.txt;
	table:=prsd_lbls.lbls;
	final:= parse_variables(code,table);
	handle_symbols:= final.code;

end;

{$IFDEF DEBUG}
var
	i:integer;
	current,first,last,tmp:symbol_table_ptr;
	table,table1:table_meta;
	list,list1:pointer_to_list_element;
	prsd_lbls:parsed_labels;
	inf1,inf2:symbol_info;
	final:final_table;
{$ENDIF}
begin
	{$IFDEF DEBUG}
		
		table:=init_table();
		writeln('Table initialized:)');
		list:=init_list();
		writeln('Printing the init_list');
		writeln();
		print_list(list);
		writeln();
		prsd_lbls:=parse_labels(list,table);
		list:=prsd_lbls.txt;
		table:=prsd_lbls.lbls;
		writeln('Printing the list after labels parsing');
		writeln();
		print_list(list);
		writeln('Printing the symbol table');
		
		writeln();
		{table:=add_label(table,'loop','5');
		table:=add_label(table,'loop1','15');
		table:=add_variable(table,'var1');
		table:=add_variable(table,'VaR2');
		table:=add_label(table,'end','123');}

		{print_table(table);}
		final:=parse_variables(list,table);
		writeln();
		writeln('symbol table:');
		table1.first:=final.table;
		print_table(table1);
		writeln('code:');	
		print_list(final.code);
		{writeln('Again initial code');
		list1:=init_list1();
		print_list(list1);SOME BUG HERE }
		
		{
		inf1:=find_symbol(table,'SP');
		writeln(inf1.is_in_table,' ',inf1.value);
		inf1:=find_symbol(table,'loop');
		writeln(inf1.is_in_table,' ',inf1.value);
		inf2:=find_symbol(table,'loop112');
		writeln(inf2.is_in_table,' ',inf2.value);
		inf2:=find_symbol(table,'end');
		writeln(inf2.is_in_table,' ',inf2.value);}	
	{$ENDIF}
end.

