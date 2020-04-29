page 6014471 "Touch Screen - Meta Functions"
{
    // NPR5.20/MHA/20150315 CASE 235325 Added Action Type Event for invoking Publisher function HandleMetaTriggerEvent()

    Caption = 'Touch Screen - Functions';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Touch Screen - Meta Functions";
    SourceTableView = SORTING(Code);

    layout
    {
        area(content)
        {
            grid(Control6150620)
            {
                ShowCaption = false;
                repeater(Control6150616)
                {
                    ShowCaption = false;
                    field("Code";Code)
                    {
                        NotBlank = true;
                    }
                    field(NativeLangDesc;NativeLangDesc)
                    {
                        Caption = 'Description';
                    }
                    field("Action";Action)
                    {
                    }
                }
                group(Control6150617)
                {
                    ShowCaption = false;
                    part(Control6150618;"Touch Screen - Meta F. Trans")
                    {
                        SubPageLink = "On function call"=FIELD(Code);
                    }
                    part(Control6150619;"Touch Screen - Meta Triggers")
                    {
                        Editable = NOT ("Action" = "Action"::NavEvent);
                        Enabled = NOT ("Action" = "Action"::NavEvent);
                        SubPageLink = "On function call"=FIELD(Code);
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if MetaFunctionTrans.Get(Code, Language.Code) then
          NativeLangDesc := MetaFunctionTrans.Description
        else
          NativeLangDesc := '';
    end;

    trigger OnOpenPage()
    begin
        Language.SetRange("Windows Language ID", GlobalLanguage);
          if Language.Find('-') then;
    end;

    var
        TypeFilter: Option "Report",Form,Internal,"Codeunit";
        MetaFunctionTrans: Record "Touch Screen - Meta F. Trans";
        NativeLangDesc: Text[100];
        Language: Record Language;
}

