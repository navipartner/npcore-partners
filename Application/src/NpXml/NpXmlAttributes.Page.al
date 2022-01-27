page 6151555 "NPR NpXml Attributes"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Xml Attributes';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR NpXml Attribute";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Name"; Rec."Attribute Name")
                {

                    ToolTip = 'Specifies the value of the Attribute Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Namespace; Rec.Namespace)
                {

                    Visible = NamespacesEnabled;
                    ToolTip = 'Specifies the value of the Namespace field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Field No."; Rec."Attribute Field No.")
                {

                    ToolTip = 'Specifies the value of the Attribute Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Attribute Field Name"; Rec."Attribute Field Name")
                {

                    ToolTip = 'Specifies the value of the Attribute Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Value"; Rec."Default Value")
                {

                    ToolTip = 'Specifies the value of the Default Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Only with Value"; Rec."Only with Value")
                {

                    ToolTip = 'Specifies the value of the Only with Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Default Field Type"; Rec."Default Field Type")
                {

                    ToolTip = 'Specifies the value of the Default Field Type field';
                    ApplicationArea = NPRRetail;
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

