page 6151560 "NPR NpXml Templ. Trigger Links"
{
    // NC1.01/MH/20150201  CASE 199932 Object created
    // NC1.03/MH/20150205  CASE 199932 Added field 330 Previous Filter Value and Previous Options to field 300 Link Type
    // NC1.08/MH/20150310  CASE 206395 Added function SetEnabled() for usability
    // NC2.00/MHA/20160525  CASE 240005 NaviConnect

    AutoSplitKey = true;
    Caption = 'Xml Trigger Links';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    SourceTable = "NPR NpXml Templ.Trigger Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Link Type"; "Link Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Link Type field';

                    trigger OnValidate()
                    begin
                        //-NC1.08
                        SetEnabled();
                        //+NC1.08
                    end;
                }
                field("Parent Field No."; "Parent Field No.")
                {
                    ApplicationArea = All;
                    Enabled = XmlTemplateFieldNoEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT XmlTemplateFieldNoEnabled;
                    ToolTip = 'Specifies the value of the Parent Field No. field';
                }
                field("Parent Field Name"; "Parent Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Parent Field Name field';
                }
                field("Parent Filter Value"; "Parent Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = XmlTemplateFilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT XmlTemplateFilterValueEnabled;
                    ToolTip = 'Specifies the value of the Parent Filter Value field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    Enabled = FieldNoEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT FieldNoEnabled;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Value"; "Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = FilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT FilterValueEnabled;
                    ToolTip = 'Specifies the value of the Filter Value field';
                }
                field("Previous Filter Value"; "Previous Filter Value")
                {
                    ApplicationArea = All;
                    Enabled = PreviousFilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT PreviousFilterValueEnabled;
                    ToolTip = 'Specifies the value of the Previous Filter Value field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NC1.08
        SetEnabled();
        //+NC1.08
    end;

    trigger OnAfterGetRecord()
    begin
        //-NC1.08
        SetEnabled();
        //+NC1.08
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Parent Table No." := XmlTemplateTableNo;
        "Table No." := TableNo;
    end;

    var
        XmlTemplateTableNo: Integer;
        TableNo: Integer;
        FieldNoEnabled: Boolean;
        FilterValueEnabled: Boolean;
        PreviousFilterValueEnabled: Boolean;
        XmlTemplateFieldNoEnabled: Boolean;
        XmlTemplateFilterValueEnabled: Boolean;

    local procedure SetEnabled()
    begin
        //-NC1.08
        XmlTemplateFilterValueEnabled := "Link Type" in ["Link Type"::ParentConstant, "Link Type"::ParentFilter];
        XmlTemplateFieldNoEnabled := XmlTemplateFilterValueEnabled or ("Link Type" in ["Link Type"::TableLink, "Link Type"::PreviousTableLink]);
        FieldNoEnabled := not XmlTemplateFilterValueEnabled;
        FilterValueEnabled := "Link Type" in ["Link Type"::Constant, "Link Type"::Filter];
        PreviousFilterValueEnabled := "Link Type" = "Link Type"::PreviousConstant;
        //+NC1.08
    end;

    procedure SetTemplateTriggerView(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger")
    begin
        FilterGroup(2);
        SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        FilterGroup(2);

        XmlTemplateTableNo := NpXmlTemplateTrigger."Parent Table No.";
        TableNo := NpXmlTemplateTrigger."Table No.";
    end;
}

