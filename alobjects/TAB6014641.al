table 6014641 "Tax Free POS Unit"
{
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module

    Caption = 'Tax Free POS Unit';
    LookupPageID = "Tax Free POS Units";

    fields
    {
        field(1;"POS Unit No.";Code[10])
        {
            Caption = 'POS Unit No.';
            TableRelation = Register."Register No.";
        }
        field(2;"Handler ID";Text[30])
        {
            Caption = 'Handler ID';

            trigger OnLookup()
            var
                TaxFreeManagement: Codeunit "Tax Free Handler Mgt.";
                ID: Text;
            begin
                if TaxFreeManagement.TryLookupHandler(ID) then
                  Validate("Handler ID",ID);
            end;

            trigger OnValidate()
            begin
                if StrLen(xRec."Handler ID") > 0 then
                  if ("Handler ID" <> xRec."Handler ID") then
                    if "Handler Parameters".HasValue then
                      if not Confirm(Confirm_ClearParameter, false, xRec."Handler ID") then
                        Error('');

                Clear("Handler Parameters");
            end;
        }
        field(3;"Handler Parameters";BLOB)
        {
            Caption = 'Handler Parameters';
        }
        field(4;Mode;Option)
        {
            Caption = 'Mode';
            OptionCaption = 'PROD,TEST';
            OptionMembers = PROD,TEST;
        }
        field(5;"Log Level";Option)
        {
            Caption = 'Log Level';
            OptionCaption = 'ERROR,FULL,NONE';
            OptionMembers = ERROR,FULL,"NONE";
        }
        field(6;"Check POS Terminal IIN";Boolean)
        {
            Caption = 'Check POS Terminal IIN';
        }
        field(7;"Min. Sales Amount Incl. VAT";Decimal)
        {
            Caption = 'Min. Sales Amount Incl. VAT';
            Description = 'DEPRECATED';
        }
        field(9;"Request Timeout (ms)";Integer)
        {
            Caption = 'Request Timeout (ms)';
        }
        field(10;"Store Voucher Prints";Boolean)
        {
            Caption = 'Store Voucher Prints';
        }
    }

    keys
    {
        key(Key1;"POS Unit No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        TestField("POS Unit No.");
    end;

    trigger OnModify()
    begin
        TestField("POS Unit No.");
    end;

    var
        Confirm_ClearParameter: Label 'This will delete any parameters set for handler %1.\Are you sure you want to Continue?';

    procedure IsThisHandler(HandlerID: Text): Boolean
    begin
        exit("Handler ID" = HandlerID);
    end;
}

