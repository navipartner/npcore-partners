table 6151586 "NPR Bin Transfer Profile"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Bin Transfer Profile';

    fields
    {
        field(1; ProfileCode; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; DocumentNoSeries; Code[20])
        {
            Caption = 'Document No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }

        field(20; PrintOnRelease; Boolean)
        {
            Caption = 'Print On Release';
            DataClassification = CustomerContent;
        }
        field(22; ReleasePrintType; Option)
        {
            Caption = 'Release Print Type';
            DataClassification = CustomerContent;
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(23; ReleasePrintObjectID; Integer)
        {
            Caption = 'Release Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF (ReleasePrintType = CONST(CODEUNIT)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("ReleasePrintType" = CONST(REPORT)) AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(25; ReleasePrintTemplateCode; Code[20])
        {
            Caption = 'Release Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header";
        }
        field(30; PrintOnReceive; Boolean)
        {
            Caption = 'Print On Receive';
            DataClassification = CustomerContent;
        }
        field(32; ReceivePrintType; Option)
        {
            Caption = 'Receive Print Type';
            DataClassification = CustomerContent;
            OptionCaption = 'No Print,Codeunit,Report,Template';
            OptionMembers = NO_PRINT,"CODEUNIT","REPORT",TEMPLATE;
        }
        field(33; ReceivePrintObjectID; Integer)
        {
            Caption = 'Receive Print Object ID';
            DataClassification = CustomerContent;
            TableRelation = IF (ReceivePrintType = CONST(CODEUNIT)) AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit))
            ELSE
            IF ("ReceivePrintType" = CONST(REPORT)) AllObj."Object ID" WHERE("Object Type" = CONST(Report));
        }
        field(35; ReceivePrintTemplateCode; Code[20])
        {
            Caption = 'Receive Print Template Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header";
        }
        field(40; PostToGeneralLedgerOnReceive; Boolean)
        {
            Caption = 'Post to G/L on Receive';
            DataClassification = CustomerContent;
        }
        field(52; ReasonCode; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
    }

    keys
    {
        key(Key1; ProfileCode)
        {
            Clustered = true;
        }
    }

}