# ---------- Build stage ----------
# 使用 Maven + JDK 11 官方 image 作為 Build stage
# 此階段只負責 compile 與 package，不會進入最終 runtime image
FROM maven:3.9.9-eclipse-temurin-11 AS build

# 設定 container 內的 working directory
WORKDIR /build

# 將 application source code 複製到 container
COPY . .

# 使用 Maven 進行 build
# -B (Batch mode)：適合 CI/CD pipeline，避免互動式輸入
# -q (Quiet mode)：減少 build log 輸出
# -DskipTests：跳過 unit tests，加快 build 速度
RUN mvn -B -q package -DskipTests


# ---------- Runtime stage ----------
# 使用 Tomcat 9 + JDK 11 作為 Runtime stage
# Multi-stage build 可有效減少最終 image size
FROM tomcat:9.0-jdk11-temurin

# Image metadata，方便辨識與管理
LABEL project="Vprofile"
LABEL author="Imran"

# 移除 Tomcat 預設 web applications（docs、examples 等）
# 確保 container 只部署實際 application
RUN rm -rf /usr/local/tomcat/webapps/*

# 從 Build stage 複製已編譯完成的 WAR 檔
# 命名為 ROOT.war，讓 application 直接掛載在 root context (/)
COPY --from=build /build/target/vprofile-v2.war \
  /usr/local/tomcat/webapps/ROOT.war

# 對外開放 Tomcat 預設的 8080 port
EXPOSE 8080

# 使用 catalina.sh 啟動 Tomcat
# 以前景模式 (foreground) 執行，符合 container best practice
CMD ["catalina.sh", "run"]
