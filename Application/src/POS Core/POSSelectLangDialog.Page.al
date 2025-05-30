﻿page 6150725 "NPR POS Select Lang. Dialog"
{
    Extensible = False;
    // NPR5.37/NPKNAV/20171030  CASE 290485 Transport NPR5.37 - 27 October 2017
    // NPR5.48/JDH /20181109 CASE 334163 Added Caption to Object

    Caption = 'POS Select Language Dialog';
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            field(LanguageCode; LanguageCode)
            {

                Caption = 'Select Language';
                TableRelation = Language;
                ToolTip = 'Specifies the value of the Select Language field';
                ApplicationArea = NPRRetail;

                trigger OnValidate()
                var
                    Language: Record Language;
                begin
                    Language.Get(LanguageCode);
                end;
            }
        }
    }

    actions
    {
    }

    var
        LanguageCode: Code[10];

    internal procedure GetLanguageCode(): Code[10]
    begin
        exit(LanguageCode);
    end;
}

