table 6151375 "CS UI Function Group"
{
    // NPR5.41/CLVA/20180313 CASE 306407 Object created - NP Capture Service
    // NPR5.43/CLVA/20180511 CASE 314144 Addedd Matrix to KeyDef option
    // NPR5.43/NPKNAV/20180629  CASE 304872 Transport NPR5.43 - 29 June 2018
    // NPR5.47/CLVA/20181011 CASE 307282 Added RFIDCollect,RFIDCollectPredicted,RFIDAssign,RFIDLocate and ItemSearch
    // NPR5.51/CLVA/20190610 CASE 356107 Added Refill and RFIDReceive
    // NPR5.52/CLVA/20190906 CASE 367425 Added KeyDef RFIDStoreCollect

    Caption = 'CS UI Function Group';
    LookupPageID = "CS Functions";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(11;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(12;KeyDef;Option)
        {
            Caption = 'KeyDef';
            OptionCaption = 'Input,Esc,First,Last,Code,PgUp,PgDn,LnUp,LnDn,Reset,Register,Function,Matrix,RFIDCollect,RFIDCollectPredicted,RFIDAssign,RFIDLocate,ItemSearch,Refill,RFIDReceive,RFIDStoreCollect', Locked=true;
            OptionMembers = Input,Esc,First,Last,"Code",PgUp,PgDn,LnUp,LnDn,Reset,Register,"Function",Matrix,RFIDCollect,RFIDCollectPredicted,RFIDAssign,RFIDLocate,ItemSearch,Refill,RFIDReceive,RFIDStoreCollect;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        MiniFunc.Reset;
        MiniFunc.SetRange("Function Code",Code);
        MiniFunc.DeleteAll;
    end;

    var
        MiniFunc: Record "CS UI Function";
}

