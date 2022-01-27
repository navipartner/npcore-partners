table 6150650 "NPR POS Audit Profile"
{
    Access = Internal;
    Caption = 'POS Audit Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS Audit Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; "Sale Fiscal No. Series"; Code[20])
        {
            Caption = 'Sale Fiscal No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeries: Record "No. Series";
            begin
                if "Sale Fiscal No. Series" <> '' then begin
                    NoSeries.Get("Sale Fiscal No. Series");
                    NoSeries.TestField("Default Nos.", true);
                end;
            end;
        }
        field(20; "Credit Sale Fiscal No. Series"; Code[20])
        {
            Caption = 'Credit Sale Fiscal No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeries: Record "No. Series";
            begin
                if "Credit Sale Fiscal No. Series" <> '' then begin
                    NoSeries.Get("Credit Sale Fiscal No. Series");
                    NoSeries.TestField("Default Nos.", true);
                end;
            end;
        }
        field(30; "Balancing Fiscal No. Series"; Code[20])
        {
            Caption = 'Balancing Fiscal No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeries: Record "No. Series";
            begin
                if "Balancing Fiscal No. Series" <> '' then begin
                    NoSeries.Get("Balancing Fiscal No. Series");
                    NoSeries.TestField("Default Nos.", true);
                end;
            end;
        }
        field(40; "Fill Sale Fiscal No. On"; Option)
        {
            Caption = 'Fill Sale Fiscal No. On';
            DataClassification = CustomerContent;
            OptionCaption = 'All Sales,Successful Sales';
            OptionMembers = All,Successful;
        }
        field(50; "Audit Log Enabled"; Boolean)
        {
            Caption = 'Audit Log Enabled';
            DataClassification = CustomerContent;
        }
        field(60; "Audit Handler"; Code[20])
        {
            Caption = 'Audit Handler';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
                DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
                CleanCashXCCSP: Codeunit "NPR CleanCash XCCSP Protocol";
            begin
                POSAuditLogMgt.LookupAuditHandler(Rec);

                case "Audit Handler" of
                    DEAuditMgt.HandlerCode():
                        Page.Run(Page::"NPR DE Audit Setup");
                    CleanCashXCCSP.HandlerCode():
                        Page.Run(Page::"NPR CleanCash Setup List");
                end;
            end;
        }
        field(70; "Allow Zero Amount Sales"; Boolean)
        {
            Caption = 'Allow Zero Amount Sales';
            DataClassification = CustomerContent;
        }
        field(80; "Print Receipt On Sale Cancel"; Boolean)
        {
            Caption = 'Print Receipt on Sale Cancel';
            DataClassification = CustomerContent;
        }
        field(90; "Allow Printing Receipt Copy"; Option)
        {
            Caption = 'Allow Printing Receipt Copy';
            DataClassification = CustomerContent;
            OptionCaption = 'Always,Only Once,Never';
            OptionMembers = Always,"Only Once",Never;
        }
        field(100; "Do Not Print Receipt on Sale"; Boolean)
        {
            Caption = 'Do Not Print Receipt on Sale';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(110; "Sales Ticket No. Series"; Code[20])
        {
            Caption = 'Sales Ticket No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(120; "Require Item Return Reason"; Boolean)
        {
            Caption = 'Require Item Return Reason';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnInsert()
    begin
        TestField(Code);
    end;

    trigger OnModify()
    begin
        TestField(Code);
    end;

    trigger OnRename()
    begin
        TestField(Code);
    end;
}
