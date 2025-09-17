package policies.my_audit_policy

input_type := "tf"
resource_type := "aws_instance"
default allow = false

# Production instances must have audit-logging-sg
allow {
    # Check if this is a production instance
    input.tags.Environment == "production"

    # Check if audit-logging-sg is present
    has_audit_logging_sg
}

# Non-production instances don't need audit logging
allow {
    input.tags.Environment != "production"
}

# Helper to check for audit logging security group
has_audit_logging_sg {
    sg_ref := input.vpc_security_group_ids[_]
    contains(sg_ref, "audit_logging_sg")
}