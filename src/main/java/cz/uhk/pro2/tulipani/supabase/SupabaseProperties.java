package cz.uhk.pro2.tulipani.supabase;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "supabase")
public record SupabaseProperties(
		String url,
		String serviceRoleKey
) {
}
