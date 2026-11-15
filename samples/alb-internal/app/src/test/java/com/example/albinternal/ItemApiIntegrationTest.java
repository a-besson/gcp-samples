package com.example.albinternal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

// Full application context against an in-memory H2 database in PostgreSQL
// mode: the real Flyway migrations create the schema (ddl-auto stays none),
// so these tests also prove the Flyway auto-configuration runs. H2 lacks the
// TIMESTAMPTZ alias used by V1 (applied migrations must not change): the
// INIT statement declares it as a domain.
@SpringBootTest(properties = {
    "spring.datasource.url=jdbc:h2:mem:items;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE;"
        + "INIT=CREATE DOMAIN IF NOT EXISTS TIMESTAMPTZ AS TIMESTAMP WITH TIME ZONE",
    "spring.datasource.username=sa",
    "spring.datasource.password="
})
@AutoConfigureMockMvc
class ItemApiIntegrationTest {

    @Autowired
    private MockMvc mvc;

    @Autowired
    private Flyway flyway;

    @Test
    void flywayAppliedTheMigrations() {
        assertThat(flyway.info().current()).isNotNull();
        assertThat(flyway.info().current().getVersion().getVersion()).isEqualTo("1");
    }

    @Test
    void createdItemIsListed() throws Exception {
        mvc.perform(post("/api/items")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"first\"}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").isNumber())
            .andExpect(jsonPath("$.name").value("first"))
            .andExpect(jsonPath("$.createdAt").isNotEmpty());

        mvc.perform(get("/api/items"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$[?(@.name == 'first')]").exists());
    }

    @Test
    void blankNameIsRejected() throws Exception {
        mvc.perform(post("/api/items")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"name\":\"  \"}"))
            .andExpect(status().isBadRequest());
    }

    @Test
    void probesAreExposed() throws Exception {
        mvc.perform(get("/actuator/health/readiness")).andExpect(status().isOk());
        mvc.perform(get("/actuator/health/liveness")).andExpect(status().isOk());
    }
}
