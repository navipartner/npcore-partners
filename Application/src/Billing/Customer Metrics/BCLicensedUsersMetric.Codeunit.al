codeunit 6151607 "NPR BC Licensed Users Metric" implements "NPR ICustomer Tenant Metric"
{
    Access = Internal;

    procedure GetEventType(): Enum "NPR Billing Event Type"
    begin
        exit(Enum::"NPR Billing Event Type"::BC_LICENSED_USERS_COUNT);
    end;

    procedure IsDelta(): Boolean
    begin
        exit(false);
    end;

    procedure Calculate(var MetricSync: Record "NPR Customer Metric Sync"; var Metadata: JsonObject): Decimal
    var
        User: Record User;
        UsersInPlans: Query "Users in Plans";
        TierByPlan: Dictionary of [Guid, Integer];
        TierByUser: Dictionary of [Guid, Integer];
        UsersByTier: array[3] of Integer;
        Tier: Integer;
        UserTier: Integer;
        DeviceUsersKeyTok: Label 'device_users', Locked = true;
        EssentialsUsersKeyTok: Label 'essentials_users', Locked = true;
        PremiumUsersKeyTok: Label 'premium_users', Locked = true;
    begin
        TierByPlan := GetTierByPlan();
        UsersInPlans.Open();
        while UsersInPlans.Read() do
            if TierByPlan.Get(UsersInPlans.Plan_ID, Tier) then begin
                if TierByUser.Get(UsersInPlans.User_Security_ID, UserTier) then
                    if UserTier > Tier then
                        Tier := UserTier;
                TierByUser.Set(UsersInPlans.User_Security_ID, Tier);
            end;
        UsersInPlans.Close();

        // Users are checked in the User table, because the query outer-joins User: a plan of a deleted user would pass a user state filter on the query as enabled
        User.SetRange(State, User.State::Enabled);
        User.SetLoadFields("User Security ID");
        if User.FindSet() then
            repeat
                if TierByUser.Get(User."User Security ID", Tier) then
                    UsersByTier[Tier] += 1;
            until User.Next() = 0;

        Metadata.Add(PremiumUsersKeyTok, UsersByTier[3]);
        Metadata.Add(EssentialsUsersKeyTok, UsersByTier[2]);
        Metadata.Add(DeviceUsersKeyTok, UsersByTier[1]);
        exit(UsersByTier[1] + UsersByTier[2] + UsersByTier[3]);
    end;

    local procedure GetTierByPlan() TierByPlan: Dictionary of [Guid, Integer]
    var
        PlanIds: Codeunit "Plan Ids";
    begin
        // Ranked by license price, so a user with several plans is counted once, under the highest, and the split adds up to the count
        TierByPlan.Add(PlanIds.GetDevicePlanId(), 1);
        TierByPlan.Add(PlanIds.GetDeviceISVPlanId(), 1);
        TierByPlan.Add(PlanIds.GetEssentialPlanId(), 2);
        TierByPlan.Add(PlanIds.GetEssentialISVPlanId(), 2);
        TierByPlan.Add(PlanIds.GetEssentialAttachPlanId(), 2);
        TierByPlan.Add(PlanIds.GetPremiumPlanId(), 3);
        TierByPlan.Add(PlanIds.GetPremiumISVPlanId(), 3);
    end;
}
