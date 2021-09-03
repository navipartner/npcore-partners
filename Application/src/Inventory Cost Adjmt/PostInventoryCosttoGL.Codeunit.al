#if BC17
//For BC18 and above use standard CU 2846 "Post Inventory Cost to G/L"
codeunit 6014683 "NPR Post Inventory Cost to G/L"
{
    trigger OnRun()
    var
        PostInvToGL: Report "Post Inventory Cost to G/L";
        PostMethod: Option "per Posting Group","per Entry";
    begin
        PostInvToGL.InitializeRequest(PostMethod::"per Entry", '', true);
        PostInvToGL.UseRequestPage(false);
        PostInvToGL.Run();
    end;
}
#endif