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
                field("Attribute Name"; "Attribute Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Name field';
                }
                field(Namespace; Namespace)
                {
                    ApplicationArea = All;
                    Visible = NamespacesEnabled;
                    ToolTip = 'Specifies the value of the Namespace field';
                }
                field("Attribute Field No."; "Attribute Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Field No. field';
                }
                field("Attribute Field Name"; "Attribute Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute Field Name field';
                }
                field("Default Value"; "Default Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Value field';
                }
                field("Only with Value"; "Only with Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only with Value field';
                }
                field("Default Field Type"; "Default Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default Field Type field';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Table No." := TableNo;
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

