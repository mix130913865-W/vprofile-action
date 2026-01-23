# ---------- Build stage ----------
FROM maven:3.9.9-eclipse-temurin-11 AS build

WORKDIR /build
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY . .
RUN mvn -B -q package -DskipTests

# ---------- Runtime stage ----------
FROM tomcat:9.0-jdk11-temurin

LABEL project="Vprofile"
LABEL author="Imran"

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=build /build/target/vprofile-v2.war \
  /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
