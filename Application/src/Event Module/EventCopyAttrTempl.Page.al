page 6060156 "NPR Event Copy Attr./Templ."
{
    Caption = 'Event Copy Attr./Templ.';
    DataCaptionExpression = PageCaption;
    PageType = StandardDialog;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(FromEventNo; FromEventNo)
                {

                    Caption = 'From Event No.';
                    TableRelation = Job."No." WHERE("NPR Event" = CONST(true));
                    ToolTip = 'Specifies the value of the From Event No. field';
                    ApplicationArea = NPRRetail;
                }
                field(ToEventNo; ToEventNo)
                {

                    Caption = 'To Event No.';
                    TableRelation = Job."No." WHERE("NPR Event" = CONST(true));
                    ToolTip = 'Specifies the value of the To Event No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            ValidateUserInput();
            case CopyWhat of
                CopyWhat::Attributes:
                    begin
                        EventAttrMgt.CopyAttributes('', FromEventNo, ToEventNo, ResponseMsg);
                        CopySuccess := true;
                    end;
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
        ResponseMsg: Text;

    procedure SetFromEvent(FromEventNoHere: Code[20]; CopyWhatHere: Option Attributes,CustTemplate,TeamTemplate)
    begin
        FromEventNo := FromEventNoHere;
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

