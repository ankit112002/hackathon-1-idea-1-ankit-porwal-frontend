enum StaffRole { owner, manager, waiter }

StaffRole? parseStaffRole(Object? value) {
  return switch (value) {
    'owner' => StaffRole.owner,
    'manager' => StaffRole.manager,
    'waiter' => StaffRole.waiter,
    _ => null,
  };
}
