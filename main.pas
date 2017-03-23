program main;

uses instructions_encoder,parser,symbol_handler,strutils,sysutils;


var
        file_name:ShortString;
        mnemonics:pointer_to_list_element;
        res,tmp1:bin_ptr;
        f2:text;

begin

        file_name:=paramstr(1);
        mnemonics:=parse_file(file_name);
	mnemonics:=handle_symbols(mnemonics);
        res:=list_to_bin(mnemonics);
        file_name:=file_name+'.hack';
        assign(f2,file_name);
        rewrite(f2);
        while res^.code<>'end of code' do
        begin

                writeln(f2,res^.code);

                res:=res^.next;
        end;
        close(f2);
end.

