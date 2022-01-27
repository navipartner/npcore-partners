table 6151375 "NPR CS UI Function Group"
{
    Access = Internal;

    Caption = 'CS UI Function Group';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(11; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; KeyDef; Option)
        {
            Caption = 'KeyDef';
            DataClassification = CustomerContent;
            OptionCaption = 'Input,Esc,First,Last,Code,PgUp,PgDn,LnUp,LnDn,Reset,Register,Function,Matrix,RFIDCollect,RFIDCollectPredicted,RFIDAssign,RFIDLocate,ItemSearch,Refill,RFIDReceive,RFIDStoreCollect', Locked = true;
            OptionMembers = Input,Esc,First,Last,"Code",PgUp,PgDn,LnUp,LnDn,Reset,Register,"Function",Matrix,RFIDCollect,RFIDCollectPredicted,RFIDAssign,RFIDLocate,ItemSearch,Refill,RFIDReceive,RFIDStoreCollect;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }


}

