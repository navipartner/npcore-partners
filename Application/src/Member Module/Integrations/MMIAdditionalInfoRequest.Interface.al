interface "NPR MM IAdd. Info. Request"
{
#if not BC17
    Access = Internal;
#endif

    procedure RequestAdditionalInfo(AddInfoRequest: Record "NPR MM Add. Info. Request" temporary;
                                    var AddInfoResponse: Record "NPR MM Add. Info. Response" temporary)
}
