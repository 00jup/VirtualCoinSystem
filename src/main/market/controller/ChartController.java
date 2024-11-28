package main.market.controller;

import lombok.RequiredArgsConstructor;
import main.market.service.ChartService;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@RequiredArgsConstructor
public class ChartController {
    private final ChartService chartService;
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private volatile boolean isRunning = false;
    private static final int CHART_HEIGHT = 20;
    private static final String ANSI_CLEAR = "\033[H\033[2J";
    private static final String ANSI_SAVE_CURSOR = "\033[s";
    private static final String ANSI_RESTORE_CURSOR = "\033[u";
    private static final String ANSI_MOVE_TO = "\033[%d;0H";

    public void displayLiveChart() {
        initializeTerminalUI();
    }

    public void initializeTerminalUI() {
        isRunning = true;
        clearScreen();
        drawStaticUI();
        startDataUpdates();
        startInputHandler();
    }

    private void clearScreen() {
        System.out.print(ANSI_CLEAR);
        System.out.flush();
    }

    private void drawStaticUI() {
        System.out.println("Virtual Coin System - Market View");
        System.out.println("━".repeat(50));

        for (int i = 0; i < CHART_HEIGHT; i++) {
            System.out.println();
        }

        System.out.println("━".repeat(50));
        System.out.println("Commands: (q)uit | (r)efresh | (h)elp");
        System.out.print("Enter command > ");
    }

    private void startDataUpdates() {
        scheduler.scheduleAtFixedRate(() -> {
            if (!isRunning) {
                scheduler.shutdown();
                return;
            }
            refreshChart();
        }, 0, 1, TimeUnit.SECONDS);
    }

    private void refreshChart() {
        clearScreen(); // 화면 전체를 초기화
        drawStaticUI(); // 고정된 UI 다시 출력

        System.out.printf(ANSI_MOVE_TO, 3); // 차트 시작 위치로 이동
        String chart = chartService.generateChartLines(); // Service에서 차트 생성
        System.out.println(chart);

        System.out.print("Enter command > "); // 명령어 입력 위치 출력
        System.out.flush();
    }

    private void startInputHandler() {
        try (java.util.Scanner scanner = new java.util.Scanner(System.in)) {
            while (isRunning) {
                String command = scanner.nextLine().trim().toLowerCase();
                handleCommand(command);
            }
        }
    }

    private void handleCommand(String command) {
        switch (command) {
            case "q":
                isRunning = false;
                scheduler.shutdown();
                System.out.println("Shutting down...");
                break;
            case "r":
                refreshChart();
                break;
            case "h":
                showHelp();
                break;
            default:
                System.out.print("Unknown command. Enter command > ");
        }
    }

    private void showHelp() {
        System.out.print(ANSI_SAVE_CURSOR);
        System.out.printf(ANSI_MOVE_TO, 3);
        System.out.println("Available Commands:");
        System.out.println("q - Quit the application");
        System.out.println("r - Refresh the chart data");
        System.out.println("h - Show this help message");
        try {
            Thread.sleep(3000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        refreshChart();
        System.out.print(ANSI_RESTORE_CURSOR);
        System.out.print("Enter command > ");
    }
}
