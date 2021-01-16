page 6151555 "NPR NpXml Attributes"
{
    // NC1.00 /MHA /20150113  CASE 199932 Refactored object from Web - XML
    // NC1.07 /MHA /20150309  CASE 206395 Added Field 140 Default Field Type
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.03 /MHA /20170404  CASE 267094 Added field 5105 Namespace

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

    actions
    {
    }

    trigger OnModifyRecord(): Boolean
    var
        XMLMappingAttribute: Record "NPR NpXml Attribute";
    begin
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Table No." := TableNo;
    end;

    var
        TableNo: Integer;
        NamespacesEnabled: Boolean;

    procedure SetEnabledFilters(NpXmlTemplate: Record "NPR NpXml Template")
    begin
        //-NC2.03 [267094]
        NamespacesEnabled := NpXmlTemplate."Namespaces Enabled";
        //+NC2.03 [267094]
    end;

    procedure SetTableNo(NewTableNo: Integer)
    begin
        TableNo := NewTableNo;
    end;
}

