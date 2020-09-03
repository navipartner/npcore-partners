page 6060156 "NPR Event Copy Attr./Templ."
{
    // NPR5.29/NPKNAV/20170127  CASE 248723 Transport NPR5.29 - 27 januar 2017
    // NPR5.31/TJ  /20170405 CASE 269162 Added FromType and ToType controls
    //                                   Recoded functions and added new functions for lookup and validate
    // NPR5.32/TJ  /20170523 CASE 275974 Renamed page
    // NPR5.33/TJ  /20170607 CASE 277972 Commented part related to deleted field Event Attribute Template Name

    Caption = 'Event Copy Attr./Templ.';
    DataCaptionExpression = PageCaption;
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(FromEventNo; FromEventNo)
                {
                    ApplicationArea = All;
                    Caption = 'From Event No.';
                    TableRelation = Job."No." WHERE("NPR Event" = CONST(true));
                }
                field(ToEventNo; ToEventNo)
                {
                    ApplicationArea = All;
                    Caption = 'To Event No.';
                    TableRelation = Job."No." WHERE("NPR Event" = CONST(true));
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        JobFrom: Record Job;
        JobTo: Record Job;
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            ValidateUserInput();
            case CopyWhat of
                //-NPR5.31 [269162]
                //CopyWhat::Attributes: CopySuccess:= EventMgt.CopyAttributes(FromEventNo,ToEventNo,ResponseMsg);
                CopyWhat::Attributes:
                    begin
                        //-NPR5.33 [277972]
                        /*
                        JobFrom.GET(FromEventNo);
                        JobTo.GET(ToEventNo);
                        JobTo.VALIDATE("Event Attribute Template Name",JobFrom."Event Attribute Template Name");
                        JobTo.MODIFY;
                        */
                        //+NPR5.33 [277972]
                        EventAttrMgt.CopyAttributes('', FromEventNo, ToEventNo, ResponseMsg);
                        CopySuccess := true;
                    end;
                //-NPR5.31 [269162]
                CopyWhat::CustTemplate, CopyWhat::TeamTemplate:
                    CopySuccess := EventMgt.CopyTemplates(FromEventNo, ToEventNo, CopyWhat, ResponseMsg);
            end;
            if CopySuccess then
                Message(CopySuccessTxt)
            else
                Error(ResponseMsg);
        end;

    end;

    var
        FromEventNo: Code[20];
        ToEventNo: Code[20];
        CantCopyToSameEvent: Label 'You can''t copy to same event.';
        SpecifyFromToEvents: Label 'You need to specify both From and To events.';
        EventMgt: Codeunit "NPR Event Management";
        CopySuccessTxt: Label 'Successfully copied to selected event.';
        EventAttrMgt: Codeunit "NPR Event Attribute Mgt.";
        CopyWhat: Option Attributes,CustTemplate,TeamTemplate;
        PageCaption: Text;
        CopyAttributesTxt: Label 'Copy Attributes';
        CopyCustTemplateTxt: Label 'Copy Customer Template';
        CopyTeamTemplateTxt: Label 'Copy Team Template';
        CopySuccess: Boolean;
        NothingToCopyTxt: Label 'There was nothing to copy.';
        ResponseMsg: Text;

    procedure SetFromEvent(FromEventNoHere: Code[20]; CopyWhatHere: Option Attributes,CustTemplate,TeamTemplate)
    begin
        //-NPR5.31 [269162]
        //FromEventNo := EventHere."No.";
        FromEventNo := FromEventNoHere;
        //+NPR5.31 [269162]
        CopyWhat := CopyWhatHere;
        case CopyWhat of
            CopyWhat::Attributes:
                PageCaption := CopyAttributesTxt;
            CopyWhat::CustTemplate:
                PageCaption := CopyCustTemplateTxt;
            CopyWhat::TeamTemplate:
                PageCaption := CopyTeamTemplateTxt;
        end;
    end;

    local procedure ValidateUserInput()
    begin
        if (FromEventNo = '') or (ToEventNo = '') then
            Error(SpecifyFromToEvents);

        if FromEventNo = ToEventNo then
            Error(CantCopyToSameEvent);
    end;
}

