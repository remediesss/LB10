#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <limits.h>
#include <locale.h>

void generate_adjacency_matrix_oriented(int n, int** matrix) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            matrix[i][j] = 0;
        }
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (i != j) {
                int edge = rand() % 2;
                if (edge == 1) {
                    matrix[i][j] = rand() % 10 + 1;
                }
            }
        }
    }
}

void generate_adjacency_matrix_undirected(int n, int** matrix) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            matrix[i][j] = 0;
        }
    }

    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            int edge = rand() % 2;
            if (edge == 1) {
                int weight = rand() % 10 + 1;
                matrix[i][j] = weight;
                matrix[j][i] = weight;
            }
        }
    }
}

void dijkstra(int** matrix, int n, int start, int* distances) {
    for (int i = 0; i < n; i++) {
        distances[i] = INT_MAX;
    }
    distances[start] = 0;

    int* visited = (int*)malloc(n * sizeof(int));
    for (int i = 0; i < n; i++) {
        visited[i] = 0;
    }

    for (int count = 0; count < n - 1; count++) {
        int min_distance = INT_MAX;
        int min_index;

        for (int v = 0; v < n; v++) {
            if (visited[v] == 0 && distances[v] <= min_distance) {
                min_distance = distances[v];
                min_index = v;
            }
        }

        visited[min_index] = 1;

        for (int i = 0; i < n; i++) {
            if (!visited[i] && matrix[min_index][i] > 0 &&
                distances[min_index] != INT_MAX &&
                distances[min_index] + matrix[min_index][i] < distances[i]) {
                distances[i] = distances[min_index] + matrix[min_index][i];
            }
        }
    }

    free(visited);
}

void calculate_shortest_paths(int** matrix, int n, int** shortest_paths) {
    for (int i = 0; i < n; i++) {
        dijkstra(matrix, n, i, shortest_paths[i]);
    }
}

void calculate_radius_diameter(int** matrix, int n, int* radius, int* diameter) {
    *radius = INT_MAX;
    *diameter = 0;

    for (int i = 0; i < n; i++) {
        int* distances = (int*)malloc(n * sizeof(int));
        dijkstra(matrix, n, i, distances);

        int max_distance = 0;
        for (int j = 0; j < n; j++) {
            if (distances[j] < INT_MAX) {
                max_distance = (max_distance > distances[j]) ? max_distance : distances[j];
            }
        }

        if (max_distance < *radius) {
            *radius = max_distance;
        }

        if (max_distance > *diameter) {
            *diameter = max_distance;
        }

        free(distances);
    }
}

void calculate_central_and_peripheral_vertices(int** matrix, int n) {
    int* max_distances = (int*)malloc(n * sizeof(int));
    int min_max_distance = INT_MAX;
    int max_distance = 0;

    for (int i = 0; i < n; i++) {
        int* distances = (int*)malloc(n * sizeof(int));
        dijkstra(matrix, n, i, distances);

        max_distance = 0;
        for (int j = 0; j < n; j++) {
            if (distances[j] < INT_MAX) {
                max_distance = (max_distance > distances[j]) ? max_distance : distances[j];
            }
        }

        max_distances[i] = max_distance;

        if (max_distance < min_max_distance) {
            min_max_distance = max_distance;
        }

        free(distances);
    }

    printf("Центральные вершины: ");
    for (int i = 0; i < n; i++) {
        if (max_distances[i] == min_max_distance) {
            printf("%d ", i);
        }
    }
    printf("\n");

    printf("Периферийные вершины: ");
    for (int i = 0; i < n; i++) {
        if (max_distances[i] == max_distance) {
            printf("%d ", i);
        }
    }
    printf("\n");

    free(max_distances);
}

int main() {
    setlocale(LC_ALL, "Rus");
    srand((unsigned)time(0));

    int n;
    printf("Введите количество вершин графа: ");
    scanf("%d", &n);

    int** matrix = (int**)malloc(n * sizeof(int*));
    for (int i = 0; i < n; i++) {
        matrix[i] = (int*)malloc(n * sizeof(int));
    }

    char choice;
    printf("Сгенерировать ориентированный (o) или неориентированный (u) граф? ");
    scanf(" %c", &choice);

    if (choice == 'o') {
        generate_adjacency_matrix_oriented(n, matrix);
    }
    else if (choice == 'u') {
        generate_adjacency_matrix_undirected(n, matrix);
    }
    else {
        fprintf(stderr, "Ошибка: неверный ввод.\n");
        return 1;
    }

    printf("Матрица смежности:\n");
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            printf("%d\t", matrix[i][j]);
        }
        printf("\n");
    }

    //матрица кратчайших расстояний
    int** shortest_paths = (int**)malloc(n * sizeof(int*));
    for (int i = 0; i < n; i++) {
        shortest_paths[i] = (int*)malloc(n * sizeof(int));
    }
    calculate_shortest_paths(matrix, n, shortest_paths);

    printf("Матрица кратчайших расстояний:\n");
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            if (shortest_paths[i][j] == INT_MAX) {
                printf("INF\t");
            }
            else {
                printf("%d\t", shortest_paths[i][j]);
            }
        }
        printf("\n");
    }

    int radius, diameter;
    calculate_radius_diameter(matrix, n, &radius, &diameter);

    printf("Радиус графа: %d\n", radius);
    printf("Диаметр графа: %d\n", diameter);

    calculate_central_and_peripheral_vertices(matrix, n);

    for (int i = 0; i < n; i++) {
        free(matrix[i]);
        free(shortest_paths[i]);
    }
    free(matrix);
    free(shortest_paths);

    return 0;
}
