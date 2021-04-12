page 6151555 "NPR NpXml Attributes"
{
    AutoSplitKey = true;
    Caption = 'Xml Attributes';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpXml Attribute";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Name"; Rec."Attribute Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Name field';
                }
                field(Namespace; Rec.Namespace)
                {
                    ApplicationArea = All;
                    Visible = NamespacesEnabled;
                    ToolTip = 'Specifies the value of the Namespace field';
                }
                field("Attribute Field No."; Rec."Attribute Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Field No. field';
                }
                field("Attribute Field Name"; Rec."Attribute Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Field Name field';
                }
                field("Default Value"; Rec."Default Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Value field';
                }
                field("Only with Value"; Rec."Only with Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only with Value field';
                }
                field("Default Field Type"; Rec."Default Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Field Type field';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Table No." := TableNo;
    end;

    var
        TableNo: Integer;
        NamespacesEnabled: Boolean;

    procedure SetEnabledFilters(NpXmlTemplate: Record "NPR NpXml Template")
    begin
        NamespacesEnabled := NpXmlTemplate."Namespaces Enabled";
    end;

    procedure SetTableNo(NewTableNo: Integer)
    begin
        TableNo := NewTableNo;
    end;
}

