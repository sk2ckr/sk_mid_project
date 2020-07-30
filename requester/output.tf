output "alb_domain_names" {
	value = {
        for alb in module.alb_auto_scaling.alb:
        alb.name => alb.dns_name...
    }
}
