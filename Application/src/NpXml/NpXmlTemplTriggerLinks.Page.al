﻿page 6151560 "NPR NpXml Templ. Trigger Links"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Xml Trigger Links';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR NpXml Templ.Trigger Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Link Type"; Rec."Link Type")
                {

                    ToolTip = 'Specifies the value of the Link Type field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetEnabled();
                    end;
                }
                field("Parent Field No."; Rec."Parent Field No.")
                {

                    Enabled = XmlTemplateFieldNoEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT XmlTemplateFieldNoEnabled;
                    ToolTip = 'Specifies the value of the Parent Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Field Name"; Rec."Parent Field Name")
                {

                    ToolTip = 'Specifies the value of the Parent Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Parent Filter Value"; Rec."Parent Filter Value")
                {

                    Enabled = XmlTemplateFilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT XmlTemplateFilterValueEnabled;
                    ToolTip = 'Specifies the value of the Parent Filter Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Field No."; Rec."Field No.")
                {

                    Enabled = FieldNoEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT FieldNoEnabled;
                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Value"; Rec."Filter Value")
                {

                    Enabled = FilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT FilterValueEnabled;
                    ToolTip = 'Specifies the value of the Filter Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Previous Filter Value"; Rec."Previous Filter Value")
                {

                    Enabled = PreviousFilterValueEnabled;
                    Style = Subordinate;
                    StyleExpr = NOT PreviousFilterValueEnabled;
                    ToolTip = 'Specifies the value of the Previous Filter Value field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEnabled();
    end;

    trigger OnAfterGetRecord()
    begin
        SetEnabled();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Parent Table No." := XmlTemplateTableNo;
        Rec."Table No." := TableNo;
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
        XmlTemplateFilterValueEnabled := Rec."Link Type" in [Rec."Link Type"::ParentConstant, Rec."Link Type"::ParentFilter];
        XmlTemplateFieldNoEnabled := XmlTemplateFilterValueEnabled or (Rec."Link Type" in [Rec."Link Type"::TableLink, Rec."Link Type"::PreviousTableLink]);
        FieldNoEnabled := not XmlTemplateFilterValueEnabled;
        FilterValueEnabled := Rec."Link Type" in [Rec."Link Type"::Constant, Rec."Link Type"::Filter];
        PreviousFilterValueEnabled := Rec."Link Type" = Rec."Link Type"::PreviousConstant;
    end;

    internal procedure SetTemplateTriggerView(NpXmlTemplateTrigger: Record "NPR NpXml Template Trigger")
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Xml Template Code", NpXmlTemplateTrigger."Xml Template Code");
        Rec.SetRange("Xml Template Trigger Line No.", NpXmlTemplateTrigger."Line No.");
        Rec.FilterGroup(2);

        XmlTemplateTableNo := NpXmlTemplateTrigger."Parent Table No.";
        TableNo := NpXmlTemplateTrigger."Table No.";
    end;
}

