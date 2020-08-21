page 6151555 "NpXml Attributes"
{
    // NC1.00 /MHA /20150113  CASE 199932 Refactored object from Web - XML
    // NC1.07 /MHA /20150309  CASE 206395 Added Field 140 Default Field Type
    // NC2.00 /MHA /20160525  CASE 240005 NaviConnect
    // NC2.03 /MHA /20170404  CASE 267094 Added field 5105 Namespace

    AutoSplitKey = true;
    Caption = 'Xml Attributes';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpXml Attribute";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Attribute Name"; "Attribute Name")
                {
                    ApplicationArea = All;
                }
                field(Namespace; Namespace)
                {
                    ApplicationArea = All;
                    Visible = NamespacesEnabled;
                }
                field("Attribute Field No."; "Attribute Field No.")
                {
                    ApplicationArea = All;
                }
                field("Attribute Field Name"; "Attribute Field Name")
                {
                    ApplicationArea = All;
                }
                field("Default Value"; "Default Value")
                {
                    ApplicationArea = All;
                }
                field("Only with Value"; "Only with Value")
                {
                    ApplicationArea = All;
                }
                field("Default Field Type"; "Default Field Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnModifyRecord(): Boolean
    var
        XMLMappingAttribute: Record "NpXml Attribute";
    begin
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Table No." := TableNo;
    end;

    var
        TableNo: Integer;
        NamespacesEnabled: Boolean;

    procedure SetEnabledFilters(NpXmlTemplate: Record "NpXml Template")
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

