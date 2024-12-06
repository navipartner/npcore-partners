codeunit 6185120 "NPR MM Unkown Add. Info. Req." implements "NPR MM IAdd. Info. Request"
{
    Access = Internal;

    internal procedure RequestAdditionalInfo(AddInfoRequest: Record "NPR MM Add. Info. Request" temporary;
                                             var AddInfoResponse: Record "NPR MM Add. Info. Response" temporary)
    var
        NoIntegrationErrText: Text[150];
        NoIntegrationErr: Label 'No integration is selected. Use the %1 for specifying integrations used on this page.';
        MemberCaptIntSetup: Record "NPR MM Member Info. Int. Setup";

    begin
        NoIntegrationErrText := StrSubstNo(NoIntegrationErr, MemberCaptIntSetup.TableCaption());
        Error(NoIntegrationErrText);
    end;
}
