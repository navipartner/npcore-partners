table 6014404 "NPR Report Selection Retail"
{
    Caption = 'Usage - Retail';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Report Type"; Option)
        {
            Caption = 'Report Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Sales Receipt,Register Balancing,Price Label,Signature Receipt,Gift Voucher,,Credit Voucher,,Terminal Receipt,Large Sales Receipt,,,Exchange Label,,Customer Sales Receipt,Rental,Tailor,Order,Photo Label,,,,Warranty Certificate,Shelf Label,,,,,CustomerLocationOnSave,CustomerLocationOnTrigger,Sign,Bin Label,Sales Receipt (POS Entry),Large Sales Receipt (POS Entry),Balancing (POS Entry),Sales Doc. Confirmation (POS Entry),Large Balancing (POS Entry),Begin Workshift (POS Entry),Transfer Order,Inv.PutAway Label';
            OptionMembers = "Sales Receipt","Register Balancing","Price Label","Signature Receipt","Gift Voucher",,"Credit Voucher",,"Terminal Receipt","Large Sales Receipt",,,"Exchange Label",,"Customer Sales Receipt",Rental,Tailor,"Order","Photo Label",,,,"Warranty Certificate","Shelf Label",,,,,CustomerLocationOnSave,CustomerLocationOnTrigger,Sign,"Bin Label","Sales Receipt (POS Entry)","Large Sales Receipt (POS Entry)","Balancing (POS Entry)","Sales Doc. Confirmation (POS Entry)","Large Balancing (POS Entry)","Begin Workshift (POS Entry)","Transfer Order","Inv.PutAway Label";
        }
        field(2; Sequence; Code[10])
        {
            Caption = 'Sequence';
            DataClassification = CustomerContent;
            Numeric = true;
        }
        field(3; "Report ID"; Integer)
        {
            Caption = 'Report ID';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Report));

            trigger OnValidate()
            begin
                CalcFields("Report Name");
            end;
        }
        field(4; "Report Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Report),
                                                                           "Object ID" = FIELD("Report ID")));
            Caption = 'Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "XML Port ID"; Integer)
        {
            Caption = 'XML Port ID';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(XMLport));

            trigger OnValidate()
            begin
                CalcFields("XML Port Name");
            end;
        }
        field(6; "XML Port Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(XMLport),
                                                                           "Object ID" = FIELD("XML Port ID")));
            Caption = 'XML Port Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(9; "Codeunit ID"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Codeunit));

            trigger OnValidate()
            begin
                CalcFields("Codeunit Name");
            end;
        }
        field(10; "Codeunit Name"; Text[249])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Codeunit),
                                                                           "Object ID" = FIELD("Codeunit ID")));
            Caption = 'Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Print Template"; Code[20])
        {
            Caption = 'Print Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
        }
        field(12; "Filter Object ID"; Integer)
        {
            Caption = 'Filter Object ID';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(13; "Record Filter"; TableFilter)
        {
            Caption = 'Record Filter';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR4.18
                if Format("Record Filter") <> '' then
                    TestField("Filter Object ID");
                //+NPR4.18
            end;
        }
        field(15; Optional; Boolean)
        {
            Caption = 'Optional';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Report Type", Sequence)
        {
        }
        key(Key2; "Report Type", "Report ID", "Register No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        ReportSelectionRetail2: Record "NPR Report Selection Retail";

    procedure NewRecord()
    begin
        ReportSelectionRetail2.SetRange("Report Type", "Report Type");
        if ReportSelectionRetail2.FindLast and (ReportSelectionRetail2.Sequence <> '') then
            Sequence := IncStr(ReportSelectionRetail2.Sequence)
        else
            Sequence := '1';
    end;
}

