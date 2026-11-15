package com.example.albinternal;

import javax.sql.DataSource;
import org.flywaydb.core.Flyway;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

// Spring Boot 4.0 moved the Flyway auto-configuration into its own module
// (spring-boot-flyway, pulled by spring-boot-starter-flyway), which this app
// does not depend on: with flyway-core alone nothing calls migrate(), so
// spring.flyway.enabled has no consumer. Migrate explicitly here, reusing
// the app's own DataSource/HikariPool. An ApplicationRunner executes after
// the context (and its JPA EntityManagerFactory, harmless with ddl-auto:
// none) is up but before the readiness probe can pass.
@Component
public class FlywayMigrationRunner implements ApplicationRunner {

    private final DataSource dataSource;

    public FlywayMigrationRunner(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public void run(ApplicationArguments args) {
        Flyway.configure().dataSource(dataSource).load().migrate();
    }
}
